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
      # Blackwell (RTX 50xx) is unsupported by the proprietary kernel module.
      open = true;
      # Saves VRAM across suspend; needed for a clean resume (Moonlight wake).
      powerManagement.enable = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  programs.xwayland.enable = true;
}
