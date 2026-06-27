{ config, pkgs, ... }:
{
  hardware = {
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        nvidia-vaapi-driver
      ];
    };
    nvidia = {
      modesetting.enable = true;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  programs.xwayland.enable = true;
}
