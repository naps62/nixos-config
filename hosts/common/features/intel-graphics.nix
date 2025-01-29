{ config, pkgs, ... }:
{
  services.xserver.videoDrivers = [ "intel" ];
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      vpl-gpu-rt # or intel-media-sdk for QSV
    ];
  };

  programs.xwayland.enable = true;
}
