{
  pkgs,
  inputs,
  ...
}:
# The user services this box exists to run, ported from hand-written units in
# ~/.config/systemd/user on the Ubuntu machine.
#
# NOT self-contained: every ExecStart under ~/.bun or ~/.local/bin is an
# imperatively-installed binary, and the WorkingDirectories are clones of
# separate repos. Nix owns the unit definitions here, nothing more.
let
  # A user unit gets almost no PATH by default; these are the profile dirs the
  # original units got for free from the system PATH on Ubuntu.
  toolPath = "%h/.local/bin:%h/.nix-profile/bin:/etc/profiles/per-user/naps62/bin:/run/current-system/sw/bin";

  sem = inputs.sem.packages.${pkgs.system}.default;

  # runtimeInputs is prepended to PATH, not a replacement, so `claude` still
  # resolves from the unit's own PATH.
  claude-rc-run = pkgs.writeShellApplication {
    name = "claude-rc-run";
    runtimeInputs = with pkgs; [
      git
      gawk
      coreutils
    ];
    text = builtins.readFile ./bin/claude-rc-run;
  };

  claude-rc = pkgs.writeShellApplication {
    name = "claude-rc";
    runtimeInputs = with pkgs; [
      git
      gawk
      gnused
      gnugrep
      coreutils
      systemd
    ];
    text = builtins.readFile ./bin/claude-rc;
  };
in
{
  home.packages = [
    claude-rc
    sem
    pkgs.bun
  ];

  systemd.user.services = {
    rev = {
      Unit = {
        Description = "rev — always-on local code review server";
        After = [ "network.target" ];
      };
      Service = {
        Type = "simple";
        WorkingDirectory = "%h/tea/rev";
        # nodejs_26, not pkgs.nodejs: rev's package.json sets engines >=26 and
        # the nixpkgs default is 24.
        ExecStart = "${pkgs.nodejs_26}/bin/node server/index.ts";
        Environment = [
          "NODE_ENV=production"
          "REV_ROOTS=%h"
          "REV_DEPTH=3"
          "REV_SEM_BIN=${sem}/bin/sem"
          "PATH=${toolPath}"
        ];
        Restart = "always";
        RestartSec = 2;
      };
      Install.WantedBy = [ "default.target" ];
    };

    rev-deploy = {
      Unit = {
        Description = "rev-deploy — Gitea webhook listener that deploys rev on push to main";
        After = [ "network.target" ];
      };
      Service = {
        Type = "simple";
        WorkingDirectory = "%h/tea/rev";
        ExecStart = "${pkgs.bun}/bin/bun scripts/deploy-webhook.ts";
        EnvironmentFile = "%h/.config/rev/deploy.env";
        Environment = [ "PATH=${toolPath}" ];
        Restart = "always";
        RestartSec = 2;
      };
      Install.WantedBy = [ "default.target" ];
    };

    claude-rc-sync = {
      Unit.Description = "Reconcile Claude Remote Control servers with the project list";
      Service = {
        Type = "oneshot";
        ExecStart = "${claude-rc}/bin/claude-rc sync";
        Environment = [ "PATH=${toolPath}" ];
      };
    };

    hourlog = {
      Unit = {
        Description = "Start the Friday hour log in a tmux session";
        Documentation = [ "https://git.naps.pt/yolo/agent-skills" ];
        ConditionPathIsDirectory = "%h/tea/agent-skills";
      };
      Service = {
        Type = "oneshot";
        ExecStart = "%h/tea/agent-skills/bin/hourlog-session.sh";
        Environment = [ "PATH=${toolPath}" ];
        # This unit may be what starts the tmux server; the default cgroup kill
        # would take it back down as soon as ExecStart returns.
        KillMode = "process";
      };
    };

    week-review = {
      Unit = {
        Description = "Start the weekly agent-skills review in a tmux session";
        Documentation = [ "https://git.naps.pt/yolo/agent-skills" ];
        ConditionPathIsDirectory = "%h/tea/agent-skills";
      };
      Service = {
        Type = "oneshot";
        ExecStart = "%h/tea/agent-skills/bin/week-review-session.sh";
        Environment = [ "PATH=${toolPath}" ];
        KillMode = "process";
      };
    };
  };

  systemd.user.timers = {
    hourlog = {
      Unit.Description = "Friday hour log, 18:00 Europe/Lisbon";
      Timer = {
        # Zone suffix pinned because the machine clock is UTC; keeps it at 18:00
        # wall time across DST.
        OnCalendar = "Fri 18:00 Europe/Lisbon";
        Persistent = true;
        AccuracySec = "1min";
      };
      Install.WantedBy = [ "timers.target" ];
    };

    week-review = {
      Unit.Description = "Weekly agent-skills review, Fridays 17:00 Europe/Lisbon";
      Timer = {
        OnCalendar = "Fri 17:00 Europe/Lisbon";
        Persistent = true;
        AccuracySec = "1min";
      };
      Install.WantedBy = [ "timers.target" ];
    };
  };

  # A plain file, NOT systemd.user.services: home-manager tries to start every
  # unit it manages, and starting a template without an instance is an error
  # ("missing the instance name"). Instances are enabled by `claude-rc sync`,
  # which needs the [Install] section below to exist.
  xdg.configFile."systemd/user/claude-rc@.service".text = ''
    [Unit]
    Description=Claude Code Remote Control (/%I)
    Documentation=https://code.claude.com/docs/en/remote-control
    After=network-online.target
    Wants=network-online.target
    StopWhenUnneeded=no

    [Service]
    Type=simple
    # Leading "-": a missing dir must not be fatal, or systemd fails with
    # 200/CHDIR before claude-rc-run can report the friendlier exit 78.
    WorkingDirectory=-/%I
    Environment=PATH=${toolPath}
    ExecStart=${claude-rc-run}/bin/claude-rc-run /%I
    # `always`, not `on-failure`: a >10min outage times the session out and the
    # process exits 0, which on-failure would not restart.
    Restart=always
    RestartSec=15
    # 78 = dir gone; 200 = systemd CHDIR failure. Without these, a deleted
    # project dir restart-loops every 15s forever.
    RestartPreventExitStatus=78 200
    StandardOutput=append:%h/.local/state/claude-rc/%i.log
    StandardError=inherit

    [Install]
    WantedBy=default.target
  '';

  systemd.user.paths.claude-rc = {
    Unit.Description = "Watch the Claude Remote Control project list for edits";
    Path = {
      PathChanged = "%h/.config/claude-rc/projects";
      Unit = "claude-rc-sync.service";
    };
    Install.WantedBy = [ "default.target" ];
  };
}
