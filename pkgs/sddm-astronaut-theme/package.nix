{ pkgs, ... }:

pkgs.stdenv.mkDerivation {
  pname = "sddm-astronaut-theme";
  version = "1.0";

  src = pkgs.fetchFromGitHub {
    owner = "Keyitdev";
    repo = "sddm-astronaut-theme";
    rev = "master";
    sha256 = "sha256-4v5QDYxNZRT7R35VL0O1UALBCCBDJalv5SeHv/lh7HM=";
  };

  installPhase = ''
    mkdir -p $out/share/sddm/themes/sddm-astronaut-theme
    cp -r * $out/share/sddm/themes/sddm-astronaut-theme/
  '';

  meta = with pkgs.lib; {
    description = "Modern astronaut-themed SDDM login theme";
    homepage = "https://github.com/Keyitdev/sddm-astronaut-theme";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
