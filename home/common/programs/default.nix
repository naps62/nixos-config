{
  lib,
  config,
  ...
}:
{
  imports = [
    ./zsh.nix
    ./nix.nix
    ./neovim
    ./rust.nix
    ./elixir.nix
    ./nodejs.nix
    ./git
    ./solidity.nix
    ./dev.nix
    ./cpp.nix
    ./claude
    ./opencode
    ./yazi
    ./ssh.nix
    ./tmux.nix
  ];

  programs = {
    home-manager.enable = true;
  };

  home = {
    username = lib.mkDefault "naps62";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "24.05";
    sessionPath = [ "$HOME/.local/bin" ];
  };
}
