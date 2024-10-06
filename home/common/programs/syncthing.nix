{ pkgs, ... }:
{
  services.syncthing = {
    enable = true;
    extraOptions = [ "--home=$HOME/sync" ];
  };
}
