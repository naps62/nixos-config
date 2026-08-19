{ pkgs, ... }:
{
  home.packages = with pkgs; [
    doctl
    awscli2
    terraform
    bruno
    coturn
    usbutils
    ktlint
  ];
}
