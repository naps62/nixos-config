{
  pkgs,
  inputs,
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
    ../common/features/xdg.nix
    ../common/features/downloads-cleanup.nix
    ./monitors.nix
    ./services.nix
  ];

  custom.hyprland.cursorSize = 32;

  # The agent session manager the hourlog/week-review timers drive. Was a
  # hand-installed binary in ~/.local/bin on the Ubuntu box.
  home.packages = [ inputs.agent-of-empires.packages.${pkgs.system}.default ];

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
