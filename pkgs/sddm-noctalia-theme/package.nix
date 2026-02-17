{ pkgs, ... }:

pkgs.stdenv.mkDerivation {
  pname = "sddm-noctalia-theme";
  version = "1.0";

  src = pkgs.fetchFromGitHub {
    owner = "mahaveergurjar";
    repo = "sddm";
    rev = "noctalia";
    sha256 = "1a9xb9hkci2bkfmq04lhd66aa60kkf97c16knrm4sgpwqdpvzba1";
  };

  installPhase = ''
    mkdir -p $out/share/sddm/themes/sddm-noctalia
    cp -r * $out/share/sddm/themes/sddm-noctalia/

    # Patch for Qt6 SDDM greeter compatibility
    # SDDM reads QtVersion from metadata.desktop to find the greeter binary;
    # default is 5 (sddm-greeter), we need 6 (sddm-greeter-qt6)
    substituteInPlace $out/share/sddm/themes/sddm-noctalia/metadata.desktop \
      --replace-fail "Theme-Id=noctalia" "QtVersion=6
    Theme-Id=noctalia"
    substituteInPlace $out/share/sddm/themes/sddm-noctalia/Main.qml \
      --replace-fail "import QtGraphicalEffects 1.12" "import Qt5Compat.GraphicalEffects"
  '';

  meta = with pkgs.lib; {
    description = "Noctalia-themed SDDM login theme";
    homepage = "https://github.com/mahaveergurjar/sddm/tree/noctalia";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
