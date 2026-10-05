{ inputs, pkgs, ... }:
let
  # Hyprland runs against glibc/libstdc++ from its own pinned nixpkgs, so it
  # cannot dlopen a newer system mesa (needs GLIBC_2.43): GBM then fails to open
  # the GPU and Hyprland aborts on start. Take the driver from the same nixpkgs.
  hyprNixpkgs = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  services.xserver.videoDrivers = [ "intel" ];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    package = hyprNixpkgs.mesa;
    package32 = hyprNixpkgs.pkgsi686Linux.mesa;
    extraPackages = with pkgs; [
      vpl-gpu-rt # or intel-media-sdk for QSV
      libva-vdpau-driver
      intel-media-driver
      intel-vaapi-driver
    ];
  };

  programs.xwayland.enable = true;
}
