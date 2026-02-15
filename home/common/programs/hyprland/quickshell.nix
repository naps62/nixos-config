{ inputs, pkgs, ... }:
{
  home.packages = [
    inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  xdg.configFile."quickshell" = {
    source = ./quickshell;
    recursive = true;
  };
}
