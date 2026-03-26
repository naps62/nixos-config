{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ../features/mutable-file.nix
    ./zsh.nix
    ./neovim
    ./rust.nix
    ./elixir.nix
    ./nodejs.nix
    ./git
    ./solidity.nix
    ./dev.nix
    ./aider.nix
    ./cpp.nix
    ./claude
    ./opencode
    ./yazi
    ./termfilechooser.nix
    ./ssh.nix
  ];

  home.mutableFilesRepoPath = "${config.home.homeDirectory}/projects/nixos-config";

  programs = {
    home-manager.enable = true;
  };

  home.packages = with pkgs; [
    impala
  ];

  home = {
    username = lib.mkDefault "naps62";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "24.05";
    sessionPath = [ "$HOME/.local/bin" ];
  };
}
