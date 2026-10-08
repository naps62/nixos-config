{ config, inputs, lib, ... }:
let
  # The Flatpak GL runtime must match the host NVIDIA driver exactly, or apps
  # fail with "Unable to create a valid OpenGL context".
  nvidiaGl = "org.freedesktop.Platform.GL.nvidia-" + builtins.replaceStrings [ "." ] [ "-" ] config.hardware.nvidia.package.version;
in

{
  imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];

  services.flatpak = {
    enable = true;

    # mkOptionDefault so the module's default `flathub` remote is kept rather
    # than replaced.
    remotes = lib.mkOptionDefault [
      {
        name = "flathub-beta";
        location = "https://flathub.org/beta-repo/flathub-beta.flatpakrepo";
      }
    ];

    packages = [
      # Tracks the driver version, so it follows nvidia bumps automatically.
      { appId = nvidiaGl; origin = "flathub"; }

      # PrusaSlicer 3.x. As of 3.0 Prusa ships no Linux binary at all — Flathub
      # is the only channel, and the alphas live in flathub-beta. Runs alongside
      # pkgs.prusa-slicer (2.9.x, in home/common/programs/3d.nix): 3.x keeps its
      # profiles in a separate PrusaSlicer3-dev config dir.
      {
        appId = "com.prusa3d.PrusaSlicer";
        origin = "flathub-beta";
      }
    ];
  };
}
