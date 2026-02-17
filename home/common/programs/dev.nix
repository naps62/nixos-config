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
    sshfs
    coturn
    file
    usbutils
    nmap
    lsof
    ktlint
    croc
    opencode

    # typst
    typst
    typstyle

    mkcert
    nss.tools
  ];
}
