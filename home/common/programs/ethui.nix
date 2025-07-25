{ inputs, ... }:
{
  home.packages = [ inputs.ethui.packages.x86_64-linux.default ];
}
