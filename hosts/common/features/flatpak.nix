{ inputs, lib, ... }:
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
