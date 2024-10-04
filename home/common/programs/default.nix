{ lib, config, ... }: {
  imports = [ ./zsh.nix ./neovim ./solidity.nix ];

  programs.gh.enable = true;

  home = {
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    sessionPath = [ "$HOME/.local/bin" ];
  };
}
