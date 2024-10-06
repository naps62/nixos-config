{ pkgs, ... }:
{
  services.syncthing = {
    enable = true;
    dataDir = "$HOME/sync";
  };
}
