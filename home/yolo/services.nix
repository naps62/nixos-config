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

  aoe = inputs.agent-of-empires.packages.${pkgs.system}.aoe-with-web;
in
{
  home.packages = [
    sem
    pkgs.bun
  ];

  systemd.user.services = {
    rev = {
      Unit = {
        Description = "rev — always-on local code review server";
        After = [ "network.target" ];
        # MUST stay 0: at RestartSec=2 a fast-crashing rev burns the default
        # 5-starts-per-10s budget, and systemd parks the unit in `failed` until
        # a manual `systemctl --user reset-failed`.
        StartLimitIntervalSec = 0;
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
        # Same restart-budget trap as `rev` above.
        StartLimitIntervalSec = 0;
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

    aoe-web = {
      Unit = {
        Description = "aoe serve — Agent of Empires web dashboard";
        After = [ "network.target" ];
        # Same restart-budget trap as `rev` above.
        StartLimitIntervalSec = 0;
      };
      Service = {
        Type = "simple";
        WorkingDirectory = "%h";
        # aoe refuses `--auth none` on a non-loopback bind unless --behind-proxy
        # is set; --allowed-host is what makes the rebinding gate accept a
        # hostname under a wildcard bind (an IP literal needs no flag).
        ExecStart = "${aoe}/bin/aoe serve --host 0.0.0.0 --port 8080 --auth none --behind-proxy --allowed-host aoe.n62.casa";
        Environment = [ "PATH=${toolPath}" ];
        Restart = "always";
        RestartSec = 2;
      };
      Install.WantedBy = [ "default.target" ];
    };

    pr-daemon = {
      Unit = {
        Description = "pr-daemon — watches GitHub/Gitea PRs and routes them to aoe sessions";
        Documentation = [ "https://git.naps.pt/yolo/agent-skills" ];
        After = [ "network.target" ];
        # Both are required and neither is in the nix store: the config names
        # the repos, the env file holds the read-only forge tokens. Missing
        # config would crash-loop against Restart=always.
        ConditionPathExists = [
          "%h/.config/reviewer/config.json"
          "%h/.config/reviewer/env"
        ];
        # Same restart-budget trap as `rev` above.
        StartLimitIntervalSec = 0;
      };
      Service = {
        Type = "simple";
        WorkingDirectory = "%h";
        ExecStart = "${pkgs.bun}/bin/bun %h/tea/agent-skills/bin/reviewer-poll.ts";
        EnvironmentFile = "%h/.config/reviewer/env";
        # aoe and git come from the profile dirs, not from a user unit's default PATH.
        Environment = [ "PATH=${toolPath}" ];
        Restart = "always";
        RestartSec = 5;
      };
      Install.WantedBy = [ "default.target" ];
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

}
