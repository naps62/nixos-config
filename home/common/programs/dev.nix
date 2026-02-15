{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./ralph-claude-code.nix
  ];

  programs = {
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;

      # Add devenv support
      # stdlib = ''
      #   # Source devenv direnvrc for use_devenv function
      #   eval "$(devenv direnvrc)"
      # '';
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
    inputs.claude-code.packages.${pkgs.stdenv.hostPlatform.system}.default
    opencode

    # typst
    typst
    typstyle

    renderdoc

    mkcert
    nss.tools

    # claude sandbox
    bubblewrap
    socat
    libseccomp
  ];

  programs.tmux = {
    enable = true;
    extraConfig = ''
      setw -g mouse on
      set -s extended-keys on
    '';
  };
}
