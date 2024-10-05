{ pkgs, ... }: {
  home.packages = with pkgs; [rofi (callPackage ../../../pkgs/rofi-launchers/package.nix {})];

  xdg.configFile."rofi-launchers".source = pkgs.fetchFromGitHub {
    owner = "adi1090x";
    repo = "rofi";
    rev = "dce10e9";
    sha256 = "sha256-ZSosFsi/M5Gqb9gsUqS7hu89uOu9078Dus4Y+WCphZc=";
  };
}
