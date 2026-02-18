{ config, pkgs, ... }:
{
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  programs.xwayland.enable = true;

  environment.variables = {
    "WEBKIT_DISABLE_DMABUF_RENDERER" = "1";
  };

  hardware.graphics.extraPackages = with pkgs; [
    nvidia-vaapi-driver
  ];
}
