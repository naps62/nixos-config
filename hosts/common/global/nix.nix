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
      # Keep devshell build inputs alive across GC/`nh clean` so direnv/devenv
      # projects don't re-download/rebuild their shells after a cleanup.
      keep-outputs = true;
      keep-derivations = true;
    };
    # GC is handled by `nh clean` below (keep-N / keep-since semantics).
    # The two are mutually exclusive — nh asserts if nix.gc.automatic is on.
    gc.automatic = false;

    # Unauthenticated GitHub API calls (flake input fetches) are capped at
    # 60/hr and 429 quickly. The token itself must not land in /nix/store
    # (world-readable), so it lives in a plain file outside Nix's management —
    # !include reads it at nix.conf parse time instead of embedding it.
    extraOptions = ''
      !include /etc/nix/github-token.conf
    '';
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
