{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    unityhub
    code-cursor
    dotnet-sdk_8
    mono
    csharpier
  ];

  programs.vscode = {
    enable = true;
  };
}
