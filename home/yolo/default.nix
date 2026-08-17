{
  lib,
  ...
}:
{
  imports = [
    ../common/programs/default.nix
    ../common/programs/desktop
    ../common/programs/zen-browser.nix
    ../common/programs/hyprland
    ../common/programs/kitty
    ../common/programs/gpg.nix
    ../common/programs/aoe
    ../common/features/xdg.nix
    ../common/features/downloads-cleanup.nix
    ./monitors.nix
    ./services.nix
  ];

  custom.hyprland.cursorSize = 32;

  # Both default to ~/projects/nixos-config in common/programs; this clone lives
  # under ~/tea. nh.flake sets NH_FLAKE, so without it `nh home switch` with no
  # argument resolves to a path that does not exist.
  home.mutableFilesRepoPath = lib.mkForce "/home/naps62/tea/nixos-config";
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
