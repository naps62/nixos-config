{ pkgs, ... }:

pkgs.stdenv.mkDerivation {
  pname = "sddm-astronaut-theme";
  version = "1.0-pixel-sakura-v2";

  src = pkgs.fetchFromGitHub {
    owner = "Keyitdev";
    repo = "sddm-astronaut-theme";
    rev = "master";
    sha256 = "sha256-+94WVxOWfVhIEiVNWwnNBRmN+d1kbZCIF10Gjorea9M=";
  };

  installPhase = ''
    mkdir -p $out/share/sddm/themes/sddm-astronaut-theme
    cp -r * $out/share/sddm/themes/sddm-astronaut-theme/

    # Override the theme variant to pixel_sakura
    sed -i 's|ConfigFile=Themes/astronaut.conf|ConfigFile=Themes/pixel_sakura.conf|' \
      $out/share/sddm/themes/sddm-astronaut-theme/metadata.desktop
  '';

  meta = with pkgs.lib; {
    description = "Modern astronaut-themed SDDM login theme";
    homepage = "https://github.com/Keyitdev/sddm-astronaut-theme";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
