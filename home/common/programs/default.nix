{ lib, config, ... }:
{
  imports = [
    ./zsh.nix
    ./neovim
    ./rust.nix
    ./git
    ./solidity.nix
    ./asdf.nix
  ];

  programs = {
    home-manager.enable = true;
    fzf.enable = true;
  };

  home = {
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    sessionPath = [ "$HOME/.local/bin" ];
  };
}
