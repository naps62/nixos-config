{ pkgs, ... }: { home.packages = with pkgs; [ foundry-bin solc ]; }
