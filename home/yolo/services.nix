{
  pkgs,
  inputs,
  ...
}:
# The user services this box exists to run.
#
# rev comes from its own flake, so nix owns the build as well as the unit.
# aoe-web is still the odd one out: its unit is defined here and the binary
# comes from the flake input.
let
  # A user unit gets almost no PATH by default; these are the profile dirs the
  # original units got for free from the system PATH on Ubuntu.
  toolPath = "%h/.local/bin:%h/.nix-profile/bin:/etc/profiles/per-user/naps62/bin:/run/current-system/sw/bin";

  sem = inputs.sem.packages.${pkgs.system}.default;

  aoe = inputs.agent-of-empires.packages.${pkgs.system}.aoe-with-web;

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
  # sem is here as well as on rev's unit: the shell uses it directly too.
  home.packages = [
    claude-rc
    sem
    # ACP adapter aoe's structured (web) sessions spawn as `claude-agent-acp`.
    pkgs.claude-agent-acp
  ];

  # rev's unit comes from its flake module, not from the hand-written set below.
  #
  # Everything under ~, three levels deep — the worktrees live at
  # ~/<area>/<repo>/worktrees/<name>. sem gives entity-level diffs; without it
  # rev falls back to line diffs.
  services.rev = {
    enable = true;
    roots = [ "%h" ];
    depth = 3;
    semBin = "${sem}/bin/sem";
  };

  # One endpoint for every repo this config pins.
  services.nixAutodeploy = {
    enable = true;
    flake = "/home/naps62/tea/nixos-config";
    environmentFile = "%h/.config/nix-autodeploy/env";
    repos = {
      "yolo/rev".input = "rev";
      "yolo/agent-skills".input = "agent-skills";
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

    claude-rc-sync = {
      Unit.Description = "Reconcile Claude Remote Control servers with the project list";
      Service = {
        Type = "oneshot";
        ExecStart = "${claude-rc}/bin/claude-rc sync";
        Environment = [ "PATH=${toolPath}" ];
      };
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

  # systemd will not create the parent of StandardOutput=append:, and fails the
  # unit with 209/STDOUT if it is missing.
  home.file.".local/state/claude-rc/.keep".text = "";

  systemd.user.paths.claude-rc = {
    Unit.Description = "Watch the Claude Remote Control project list for edits";
    Path = {
      PathChanged = "%h/.config/claude-rc/projects";
      Unit = "claude-rc-sync.service";
    };
    Install.WantedBy = [ "default.target" ];
  };
}
# pr-daemon, hourlog and week-review are not here: their units ship with the
# scripts they run, in the agent-skills module. This host opts in with
# programs.agentSkills.*.enable in home/yolo/default.nix.
