{
  lib,
  pkgs,
  ...
}:
let
  claudeSettings = "home/yolo/claude-settings.json";

  # ./claude-settings.json holds only what yolo overrides; everything else is
  # inherited so common changes reach this host. Attrsets merge key-by-key,
  # lists are replaced whole (permissions.allow is yolo's, not a union).
  mergedClaudeSettings = (pkgs.formats.json { }).generate "claude-settings.json" (
    lib.recursiveUpdate (lib.importJSON ../common/programs/claude/settings.json) (
      lib.importJSON ./claude-settings.json
    )
  );

  # Same merge, same reason: ./opencode.json holds only yolo's overrides so
  # agents, commands and skills keep coming from common.
  mergedOpencodeConfig = (pkgs.formats.json { }).generate "opencode.json" (
    lib.recursiveUpdate (lib.importJSON ../common/programs/opencode/opencode.json) (
      lib.importJSON ./opencode.json
    )
  );
in
{
  imports = [
    ../common/programs/default.nix
    ../common/programs/desktop
    ../common/programs/hyprland
    ../common/programs/kitty
    ../common/programs/gpg.nix
    ../common/programs/aoe
    ../common/programs/maestro
    ../common/features/xdg.nix
    ./monitors.nix
    ./services.nix
    ./ssh.nix
  ];

  # Host-local, like the aoe config below: bash goes from "ask" to
  # "allow" so unattended opencode sessions stop stalling on every git and grep.
  # It also drops the prompt on branches under review, which is the tradeoff.
  xdg.configFile."opencode/opencode.json".source = lib.mkForce mergedOpencodeConfig;

  custom.hyprland.cursorSize = 32;

  # Amber, and a different silhouette to Nordzy — this desktop is only ever seen
  # inside a Moonlight window, so the cursor has to be tellable at a glance from
  # the client's own. Same theme in both modes; darkman would otherwise swap it.
  custom.hyprland.cursorPackage = pkgs.bibata-cursors;
  custom.hyprland.cursorTheme = {
    dark = "Bibata-Modern-Amber";
    light = "Bibata-Modern-Amber";
  };

  home = {
    # Headless browser driver the agent tooling shells out to. Was a global npm
    # install on the ubuntu box.
    packages = [ pkgs.agent-browser ];

    # Both default to ~/projects/nixos-config in common/programs; this clone
    # lives under ~/tea. nh.flake sets NH_FLAKE, so without it `nh home switch`
    # with no argument resolves to a path that does not exist.
    mutableFilesRepoPath = "/home/naps62/tea/nixos-config";

    mutableFiles = {
      # Host-local, not shared: this sets yolo_mode_default = true, which starts
      # aoe sessions with permission checks skipped. Only correct on this box.
      ".config/agent-of-empires/config.toml".source = ./aoe-config.toml;

      # Likewise host-local: carries skipDangerousModePermissionPrompt and the
      # rev hook paths, neither of which belong on a workstation.
      ".claude/settings.json" = {
        source = lib.mkForce mergedClaudeSettings;
        upstreamPath = claudeSettings;
      };
    };
  };

  # This is the one box that runs the agent-skills units; each starts a session,
  # so a second machine enabling them would run the same job twice.
  programs.agentSkills = {
    machine = "yolo";
    prDaemon.enable = true;
    hourlog.enable = true;
    weekReview.enable = true;
  };
  programs.nh.flake = "/home/naps62/tea/nixos-config";

  # Idle lock and dpms-off blank the virtual output: Sunshine then captures a
  # flat frame and Moonlight goes black, with no console to unlock from.
  services.hypridle.enable = lib.mkForce false;

  # Blur and shadow cost a fullscreen pass per frame, and every frame here is
  # also x264-encoded for the stream — on a virtio-gpu with no VirGL, in software.
  wayland.windowManager.hyprland.extraConfig = ''
    hl.config({
      decoration = {
        blur = { enabled = false },
        shadow = { enabled = false },
      },
    })
  '';
}
