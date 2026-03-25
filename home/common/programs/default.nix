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

  home.mutableFilesRepoPath = "/home/naps62/projects/nixos-config";

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
