{ lib, config, ... }: {
  imports = [ ./basePrograms.nix ./zsh.nix ./neovim ./solidity.nix ];

  home = {
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    sessionPath = [ "$HOME/.local/bin" ];
  };
}
