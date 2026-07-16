{
  lib,
  appimageTools,
  fetchurl,
  # UI scaling: null = native, or a string like "1.5" for --force-device-scale-factor.
  deviceScaleFactor ? null,
}:
let
  pname = "t3-code";
  version = "0.0.28";

  # T3 Code (pingdotgg/t3code): open-source control plane for coding agents.
  # Ships only an x86_64 AppImage; bump version + hash from the releases page:
  #   https://github.com/pingdotgg/t3code/releases
  src = fetchurl {
    url = "https://github.com/pingdotgg/t3code/releases/download/v${version}/T3-Code-${version}-x86_64.AppImage";
    hash = "sha256-+mBp+wPrJRV/HpaimQHcqBuwqZcPWTbKJVNCVW7ELgo=";
  };

  appimageContents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    # Desktop entry + icons from the AppImage, repointed at the wrapped binary.
    install -Dm444 ${appimageContents}/t3code.desktop $out/share/applications/t3code.desktop
    substituteInPlace $out/share/applications/t3code.desktop \
      --replace-fail "Exec=AppRun --no-sandbox" "Exec=${pname} --no-sandbox${lib.optionalString (deviceScaleFactor != null) " --force-device-scale-factor=${deviceScaleFactor}"}"
    cp -r ${appimageContents}/usr/share/icons $out/share/icons
  '';

  meta = {
    description = "Open-source control plane for coding agents (Claude Code, Codex, OpenCode, Cursor)";
    homepage = "https://t3.codes";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "t3-code";
  };
}
