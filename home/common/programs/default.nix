{ lib, config, ... }: {
  imports = [ ./zsh.nix ./neovim ./rust.nix ./solidity.nix ];

  programs = {
    home-manager.enable = true;
    git.enable = true;
    fzf.enable = true;
    gh.enable = true;
  };

  home = {
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    sessionPath = [ "$HOME/.local/bin" ];
  };
}
