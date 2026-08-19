{ pkgs, ... }:
{
  imports = [ ./desktop/spicetify.nix ];

  home.packages = with pkgs; [
    obsidian
    obs-studio
    kooha
    vokoscreen-ng
    gimp
    font-manager
    xournalpp
    remmina
    slack
    ferdium
    signal-desktop
    zoom-us
    yaak
    bun
  ];
}
