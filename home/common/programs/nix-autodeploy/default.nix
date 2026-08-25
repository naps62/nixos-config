{
  config,
  lib,
  pkgs,
  ...
}:
# nix-autodeploy: one webhook endpoint that turns "a repo I own pushed to main"
# into "that flake input is bumped, committed, and (optionally) applied".
#
# Replaces per-app deploy webhooks that rebuilt from a checkout on the box. The
# apps are flake inputs now, so deploying one is a lock bump plus a generation
# switch — the same operation for every app, hence one service instead of N.
let
  cfg = config.services.nixAutodeploy;

  # A user unit inherits almost no PATH, and the deploy shells out to git (with
  # the gitea credential helper), nix and nh.
  profilePath = lib.concatStringsSep ":" [
    "%h/.local/bin"
    "%h/.nix-profile/bin"
    "/etc/profiles/per-user/%u/bin"
    "/run/current-system/sw/bin"
  ];

  deploy = pkgs.writeShellApplication {
    name = "nix-autodeploy-deploy";
    runtimeInputs = [
      pkgs.git
      pkgs.nix
      pkgs.nh
      pkgs.curl
      pkgs.jq
      pkgs.util-linux
    ];
    text = ''
      # usage: nix-autodeploy-deploy <flake-input> <apply|notify>
      input=$1
      mode=$2
      flake=${lib.escapeShellArg cfg.flake}
      topic=${lib.escapeShellArg cfg.ntfy.topic}
      ntfy_url=${lib.escapeShellArg cfg.ntfy.url}

      notify() {
        [ -n "''${NTFY_TOKEN:-}" ] || return 0
        curl -fsS -X POST "$ntfy_url/$topic" \
          -H "Authorization: Bearer $NTFY_TOKEN" \
          -H "Title: $1" -d "$2" > /dev/null || true
      }

      # Serialize: two pushes landing together would otherwise race on the same
      # working tree and the same flake.lock.
      exec 9> "''${XDG_RUNTIME_DIR:-/tmp}/nix-autodeploy.lock"
      flock 9

      cd "$flake"

      branch=$(git rev-parse --abbrev-ref HEAD)
      if [ "$branch" != main ]; then
        notify "autodeploy skipped ($input)" "checkout is on $branch, not main"
        exit 0
      fi
      if ! git diff --quiet || ! git diff --cached --quiet; then
        notify "autodeploy skipped ($input)" "working tree is dirty"
        exit 0
      fi

      git fetch --quiet origin main
      git merge --ff-only --quiet origin/main

      nix flake update "$input"
      if git diff --quiet -- flake.lock; then
        echo "autodeploy: $input already at the pushed revision"
        exit 0
      fi

      rev=$(nix flake metadata --json |
        jq -r --arg i "$input" '.locks.nodes[$i].locked.rev[0:7]')
      git commit --quiet -m "chore(flake): bump $input to $rev" -- flake.lock
      git push --quiet origin main

      if [ "$mode" != apply ]; then
        notify "$input bumped to $rev" "Not applied — run 'nh home switch' when convenient."
        exit 0
      fi

      if nh home switch "$flake"; then
        notify "$input deployed" "Bumped to $rev and switched."
      else
        notify "$input FAILED to apply" "Lock is at $rev on main; the switch failed. See journalctl --user -u run-*."
        exit 1
      fi
    '';
  };

  listener = pkgs.writers.writePython3Bin "nix-autodeploy" {
    # Only line length: http.server's do_GET/do_POST spelling is already
    # excused inline.
    flakeIgnore = [ "E501" ];
  } (builtins.readFile ./listener.py);

  repoMap = lib.mapAttrs (_: r: {
    inherit (r) input;
    inherit (r) apply;
  }) cfg.repos;
in
{
  options.services.nixAutodeploy = {
    enable = lib.mkEnableOption "the forge-webhook listener that bumps and applies flake inputs";

    port = lib.mkOption {
      type = lib.types.port;
      default = 7375;
      description = "Port the listener binds on 0.0.0.0. There is no auth beyond the webhook HMAC, so only expose it through the reverse proxy.";
    };

    flake = lib.mkOption {
      type = lib.types.str;
      example = "/home/naps62/tea/nixos-config";
      description = "Absolute path to the nixos-config checkout whose flake.lock gets bumped. Must be on main and clean, or the deploy skips.";
    };

    environmentFile = lib.mkOption {
      type = lib.types.str;
      example = "%h/.config/nix-autodeploy/env";
      description = ''
        File holding `NIX_AUTODEPLOY_SECRET` (the webhook HMAC secret, shared
        with every repo below) and `NTFY_TOKEN`. Not in the store — these are
        secrets.
      '';
    };

    ntfy = {
      url = lib.mkOption {
        type = lib.types.str;
        default = "https://ntfy.home.naps.pt";
        description = "Base URL of the ntfy server deploy results are posted to.";
      };
      topic = lib.mkOption {
        type = lib.types.str;
        default = "nix-autodeploy";
        description = "ntfy topic for deploy results.";
      };
    };

    repos = lib.mkOption {
      default = { };
      description = "Forge repositories to listen for, keyed by `<owner>/<repo>` exactly as the webhook payload spells it.";
      example = lib.literalExpression ''
        { "yolo/rev" = { input = "rev"; }; }
      '';
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            input = lib.mkOption {
              type = lib.types.str;
              description = "Name of the flake input in this repo's flake.nix that tracks that repository.";
            };
            apply = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = ''
                Whether to run `nh home switch` after the bump. Set false for an
                app whose restart disrupts a live session — the lock is still
                bumped and pushed, and the ntfy message says it is waiting.
              '';
            };
          };
        }
      );
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.nix-autodeploy = {
      Unit = {
        Description = "nix-autodeploy — forge webhooks bump and apply flake inputs";
        After = [ "network.target" ];
        # Same restart-budget trap every other always-on unit here avoids: at
        # RestartSec=2 a fast-crashing listener would park in `failed`.
        StartLimitIntervalSec = 0;
      };
      Service = {
        Type = "simple";
        ExecStart = lib.getExe listener;
        EnvironmentFile = cfg.environmentFile;
        Environment = [
          "PATH=${profilePath}"
          "NIX_AUTODEPLOY_PORT=${toString cfg.port}"
          "NIX_AUTODEPLOY_DEPLOY_BIN=${lib.getExe deploy}"
          "NIX_AUTODEPLOY_ENV_FILE=${cfg.environmentFile}"
          "NIX_AUTODEPLOY_REPOS=${builtins.toJSON repoMap}"
        ];
        Restart = "always";
        RestartSec = 2;
      };
      Install.WantedBy = [ "default.target" ];
    };
  };
}
