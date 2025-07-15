{ inputs, ... }:
{
  home.packages = [ inputs.ethui.x86_64-linux.defaultPackages ];
}
