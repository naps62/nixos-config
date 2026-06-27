{ pkgs, inputs, ... }:
{
  imports = [
    # Prebuilt, weekly-updated nix-index database (backs `comma`).
    inputs.nix-index-database.homeModules.nix-index
  ];

  # `comma` (`,`) — run any nixpkgs program once without installing it.
  programs.nix-index.enable = true;
  programs.nix-index-database.comma.enable = true;

  home.packages = with pkgs; [
    nvd # version diff between generations (used by nh)
    nix-output-monitor # readable build output (nom; used by nh)
    statix # nix linter / antipattern finder
    deadnix # finds unused nix bindings
  ];
}
