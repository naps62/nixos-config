{
  lib,
  pkgs,
  config,
  ...
}:
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
    ./cpp.nix
    ./claude
    ./opencode
    ./yazi
    ./termfilechooser.nix
  ];

  programs = {
    home-manager.enable = true;
  };

  home.packages = with pkgs; [
    impala
  ];

  home = {
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    sessionPath = [ "$HOME/.local/bin" ];
  };
}
