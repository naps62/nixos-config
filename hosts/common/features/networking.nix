{ inputs, pkgs, ... }:
{
  networking = {
    networkmanager = {
      enable = true;
    };
    wireless.iwd.enable = true;
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
