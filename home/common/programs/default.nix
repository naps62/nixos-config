{ lib, config, ... }:
{
  imports = [
    ./zsh.nix
    ./neovim
    ./rust.nix
    ./elixir.nix
    ./nodejs.nix
    ./git
    ./solidity.nix
    ./dev.nix
    ./aider.nix
  ];

  programs = {
    home-manager.enable = true;
  };

  home = {
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    sessionPath = [ "$HOME/.local/bin" ];
  };
}
