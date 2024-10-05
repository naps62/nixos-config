{pkgs,...}:{
  home.packages = with pkgs; [rofi (callPackage ../../../../../pkgs/rofi-launchers/package.nix {})];
  }
