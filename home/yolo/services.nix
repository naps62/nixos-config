{
  pkgs,
  inputs,
  ...
}:
# The user services this box exists to run.
#
# rev comes from its own flake, so nix owns the build as well as the unit.
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
      jq
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
