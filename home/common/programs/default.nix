{
  lib,
  config,
  ...
}:
{
  imports = [
    ../features/mutable-file.nix
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
    # mkDefault: hosts whose clone lives elsewhere (yolo, under ~/tea) override
    # this with a plain assignment.
    mutableFilesRepoPath = lib.mkDefault "${config.home.homeDirectory}/projects/nixos-config";

    username = lib.mkDefault "naps62";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "24.05";
    sessionPath = [ "$HOME/.local/bin" ];
  };
}
