{
  pkgs,
  ...
}:
{
  imports = [
    ./codex.nix
    ./pi.nix
    ./ralph-claude-code.nix
    ./t3-code.nix
  ];

  programs = {
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;

      # Add devenv support
      stdlib = ''
        # Source devenv direnvrc for use_devenv function
        eval "$(devenv direnvrc)"
      '';
    };
  };

  home.packages = with pkgs; [
    imagemagick
    doctl
    awscli2
    terraform
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
    process-compose

    # typst
    typst
    typstyle

    ruby

    mkcert
    nss.tools

    tea

    just # project command runner
    lazydocker # docker TUI
    dust # du replacement
    duf # df replacement

    rtk # cli proxy the claude hooks rewrite commands through
    wget
    sqlite
    shellcheck
    cmake
    ninja
    git-filter-repo
    expect
    whois
    p7zip
    poppler-utils # pdftotext
    jpegoptim
    sshpass
  ];
}
