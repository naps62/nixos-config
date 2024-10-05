{ pkgs, ... }: {
  xdg.configFile."rofi-launchers".source = builtins.fetchFromGithub {
    owner = "adi1090x";
    repo = "rofi";
    rev = "dce10e9";
  };
}
