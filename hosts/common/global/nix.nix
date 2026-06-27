{
  lib,
  ...
}:
{
  nix = {
    settings = {
      trusted-users = [
        "root"
        "@wheel"
      ];
      auto-optimise-store = lib.mkDefault true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      warn-dirty = false;
    };
    # GC is handled by `nh clean` below (keep-N / keep-since semantics).
    # The two are mutually exclusive — nh asserts if nix.gc.automatic is on.
    gc.automatic = false;
  };

  # nh: ergonomic nixos-rebuild wrapper. Auto-detects the target from the
  # machine hostname (configs are named to match), so `nh os switch` needs
  # no host arg. Runs as root, so its `clean` prunes system + user profiles.
  programs.nh = {
    enable = true;
    flake = "/home/naps62/projects/nixos-config";
    clean = {
      enable = true;
      extraArgs = "--keep 10 --keep-since 7d";
    };
  };

  nixpkgs.config.allowUnfree = true;
}
