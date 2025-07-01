{
  lib,
  config,
  pkgs,
  ...
}:
{
  programs = {
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
  };

  home.packages = with pkgs; [
    imagemagick
    doctl
    aider-chat
    inotify-tools
    devenv
    # bruno
    zed-editor
    tmux
  ];
}
