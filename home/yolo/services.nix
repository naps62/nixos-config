{
  pkgs,
  inputs,
  ...
}:
# The user services this box exists to run.
#
# maestro and rev come from their own flakes, so nix owns the build as well as
# the unit. aoe-web is still the odd one out: its unit is defined here and the
# binary comes from the flake input.
let
  # A user unit gets almost no PATH by default; these are the profile dirs the
  # original units got for free from the system PATH on Ubuntu.
  toolPath = "%h/.local/bin:%h/.nix-profile/bin:/etc/profiles/per-user/naps62/bin:/run/current-system/sw/bin";

  sem = inputs.sem.packages.${pkgs.system}.default;

  aoe = inputs.agent-of-empires.packages.${pkgs.system}.aoe-with-web;
in
{
  # sem is here as well as on rev's unit: the shell uses it directly too.
  home.packages = [
    sem
    # ACP adapter aoe's structured (web) sessions spawn as `claude-agent-acp`.
    pkgs.claude-agent-acp
  ];

  # maestro's and rev's units come from their flake modules, not from the
  # hand-written set below. 8081, not 8080: aoe-web already has that port on
  # this host. There is no auth layer, so 0.0.0.0 is only safe behind the LAN
  # perimeter.
  services.maestro = {
    enable = true;
    web.enable = true;
    settings = {
      daemon.bind_addr = "127.0.0.1:7070";
      web = {
        bind_addr = "0.0.0.0:8081";
        daemon_url = "http://127.0.0.1:7070";
      };
    };
  };

  # Everything under ~, three levels deep — the worktrees live at
  # ~/<area>/<repo>/worktrees/<name>. sem gives entity-level diffs; without it
  # rev falls back to line diffs.
  services.rev = {
    enable = true;
    roots = [ "%h" ];
    depth = 3;
    semBin = "${sem}/bin/sem";
  };

  # One endpoint for every repo this config pins. rev and agent-skills apply
  # straight away; maestro only bumps the lock and notifies, because switching
  # restarts the daemon that owns every interactive shell on this box.
  services.nixAutodeploy = {
    enable = true;
    flake = "/home/naps62/tea/nixos-config";
    environmentFile = "%h/.config/nix-autodeploy/env";
    repos = {
      "yolo/rev".input = "rev";
      "yolo/agent-skills".input = "agent-skills";
      "naps62/maestro" = {
        input = "maestro";
        apply = false;
      };
    };
  };

  systemd.user.services = {
    aoe-web = {
      Unit = {
        Description = "aoe serve — Agent of Empires web dashboard";
        After = [ "network.target" ];
        # MUST stay 0: at RestartSec=2 a fast-crashing aoe burns the default
        # 5-starts-per-10s budget, and systemd parks the unit in `failed` until
        # a manual `systemctl --user reset-failed`.
        StartLimitIntervalSec = 0;
      };
      Service = {
        Type = "simple";
        WorkingDirectory = "%h";
        # The fork removed dashboard auth entirely, so there is no --auth flag
        # any more — the reverse proxy is the only access gate. --allowed-host
        # is what makes the rebinding gate accept a hostname under a wildcard
        # bind (an IP literal needs no flag).
        ExecStart = "${aoe}/bin/aoe serve --host 0.0.0.0 --port 8080 --behind-proxy --allowed-host aoe.n62.casa";
        # TMUX_TMPDIR keeps the daemon on the same tmux server the shell and
        # TUI use, instead of a second one under /tmp (same bug pr-daemon had).
        Environment = [
          "PATH=${toolPath}"
          "TMUX_TMPDIR=%t"
        ];
        Restart = "always";
        RestartSec = 2;
        # If this unit boots before any shell, the shared tmux server lands in
        # its cgroup; the default control-group kill would take every session
        # down on restart.
        KillMode = "process";
      };
      Install.WantedBy = [ "default.target" ];
    };
  };
}
# pr-daemon, hourlog and week-review are not here: their units ship with the
# scripts they run, in the agent-skills module. This host opts in with
# programs.agentSkills.*.enable in home/yolo/default.nix.
