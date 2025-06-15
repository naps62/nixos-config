{
  config,
  pkgs,
  inputs,
  ...
}:
{
  home.packages = with pkgs; [
    inputs.quickshell.packages.x86_64-linux.quickshell
  ];

  xdg.configFile."quickshell".source = ./quickshell;
}
