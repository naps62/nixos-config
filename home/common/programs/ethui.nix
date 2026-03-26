{ inputs, pkgs, ... }:
{
  home.packages = [ inputs.ethui.packages.${pkgs.stdenv.hostPlatform.system}.default ];
}
