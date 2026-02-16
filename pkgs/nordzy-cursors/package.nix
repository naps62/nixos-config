{ lib, stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation rec {
  pname = "nordzy-cursors";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "guillaumeboehm";
    repo = "Nordzy-cursors";
    rev = "v${version}";
    sha256 = "sha256-q9PEEyxejRQ8UCwbqsfOCL7M70pLCOLyCx8gEFmZkWA=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/icons

    # Install all Nordzy cursor themes
    for theme in Nordzy-cursors*; do
      if [ -d "$theme" ]; then
        cp -r "$theme" $out/share/icons/
      fi
    done

    runHook postInstall
  '';

  meta = with lib; {
    description = "Cursor theme using the Nord color palette";
    homepage = "https://github.com/guillaumeboehm/Nordzy-cursors";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
