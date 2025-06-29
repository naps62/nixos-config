{ inputs, pkgs, ... }:
{
  home.packages = with pkgs; [
    unityhub
    omnisharp-roslyn
    vscode
    dotnet-sdk
    icu
    stdenv.cc.cc.lib
  ];
}
