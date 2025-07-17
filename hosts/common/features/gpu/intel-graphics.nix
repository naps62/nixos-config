{ config, pkgs, ... }:
{
  services.xserver.videoDrivers = [ "intel" ];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      vpl-gpu-rt # or intel-media-sdk for QSV
      vaapiVdpau
      intel-media-driver
      intel-vaapi-driver
    ];
  };

  programs.xwayland.enable = true;
}
