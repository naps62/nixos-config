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
    # ACP adapter aoe's structured (web) sessions spawn as `claude-agent-acp`.
    pkgs.claude-agent-acp
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
        # Unit files are home-manager symlinks; deploy.sh must not rewrite them.
        Environment = [ "PATH=${toolPath}" "REV_SKIP_UNIT_INSTALL=1" ];
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
