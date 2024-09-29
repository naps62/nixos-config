{ lib, config, ... }: {
  imports = [ ./basePrograms.nix ./neovim.nix ./zsh.nix ];

  home = {
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    sessionPath = [ "$HOME/.local/bin" ];
  };
}
