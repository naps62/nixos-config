{ pkgs, inputs, ... }:
{
  imports = [
    # Prebuilt, weekly-updated nix-index database (backs `comma`).
    inputs.nix-index-database.homeModules.nix-index
  ];

  # `comma` (`,`) — run any nixpkgs program once without installing it.
  programs.nix-index.enable = true;
  programs.nix-index-database.comma.enable = true;

  # `nh` — friendlier wrapper around nix/home-manager (nh os/home switch).
  # `flake` sets NH_FLAKE so `nh home switch` finds this repo without --flake.
  programs.nh = {
    enable = true;
    flake = "/home/naps62/projects/nixos-config";
  };

  home.packages = with pkgs; [
    nvd # version diff between generations (used by nh)
    nix-output-monitor # readable build output (nom; used by nh)
    statix # nix linter / antipattern finder
    deadnix # finds unused nix bindings
  ];
}
