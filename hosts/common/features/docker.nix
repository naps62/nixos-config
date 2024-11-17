{ config, lib, ... }:
{
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = false;
    };
  };

  users.groups.docker = { };

  networking.firewall = {
    enable = false;
    # checkReversePath = false;
  };
}
