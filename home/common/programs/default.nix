{ lib, config, ... }:
{
  imports = [
    ./zsh.nix
    ./neovim
    ./rust.nix
    ./git
    ./solidity.nix
    ./dev.nix
  ];

  programs = {
    home-manager.enable = true;
  };

  home = {
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    sessionPath = [ "$HOME/.local/bin" ];
  };
}
