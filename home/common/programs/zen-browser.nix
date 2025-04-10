{ inputs, pkgs, ... }:
{
  home.packages = [ inputs.zen-browser.packages.x86_64-linux.twilight-official ];
}
