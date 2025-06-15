{ pkgs, ... }:
{
  home.packages = with pkgs; [
    esphome
    clang-tools
  ];
}
