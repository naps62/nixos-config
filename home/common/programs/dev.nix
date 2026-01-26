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
    inotify-tools
    devenv
    bruno
    zed-editor
    sshfs
    coturn
    file
    usbutils
    nmap
    lsof
    ktlint
    croc
    claude-code

    # typst
    typst
    typstyle

    renderdoc
  ];

  programs.tmux = {
    enable = true;
    extraConfig = ''
      setw -g mouse on
      set -s extended-keys on
    '';
  };
}
