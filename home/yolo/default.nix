{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../common/programs/default.nix
    ../common/programs/desktop
    ../common/programs/hyprland
    ../common/programs/kitty
    ../common/programs/gpg.nix
    ../common/programs/aoe
    ../common/features/xdg.nix
    ./monitors.nix
    ./services.nix
    ./ssh.nix
  ];

  custom.hyprland.cursorSize = 32;

  # Headless browser driver the agent tooling shells out to. Was a global npm
  # install on the ubuntu box.
  home.packages = [ pkgs.agent-browser ];

  # Both default to ~/projects/nixos-config in common/programs; this clone lives
  # under ~/tea. nh.flake sets NH_FLAKE, so without it `nh home switch` with no
  # argument resolves to a path that does not exist.
  home.mutableFilesRepoPath = lib.mkForce "/home/naps62/tea/nixos-config";

  # Host-local, not shared: this sets yolo_mode_default = true, which starts aoe
  # sessions with permission checks skipped. Only correct on this box.
  home.mutableFiles.".config/agent-of-empires/config.toml".source = ./aoe-config.toml;

  # Likewise host-local: carries skipDangerousModePermissionPrompt and the rev
  # hook paths, neither of which belong on a workstation.
  home.mutableFiles.".claude/settings.json".source = lib.mkForce ./claude-settings.json;

  programs.agentSkills.machine = "yolo";
  programs.nh.flake = lib.mkForce "/home/naps62/tea/nixos-config";

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
