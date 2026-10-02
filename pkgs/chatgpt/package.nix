{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  asar,
  glibc,
  dpkg,
  makeWrapper,
  wrapGAppsHook3,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  gdk-pixbuf,
  glib,
  gtk3,
  libGL,
  libdrm,
  libgbm,
  libnotify,
  libsecret,
  libusb1,
  libxkbcommon,
  nspr,
  nss,
  openssl,
  pango,
  systemd,
  tpm2-tss,
  wayland,
  libX11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxrandr,
  xdg-utils,
  deviceScaleFactor ? null,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "chatgpt";
  version = "26.930.21537";

  src = fetchurl {
    url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/pool/main/c/chatgpt/chatgpt_${finalAttrs.version}_amd64.deb";
    hash = "sha256-YP222JXXdviDH/NaeD3gTNv6KA8PPZclhDFfmOV6olY=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    asar
    dpkg
    makeWrapper
    wrapGAppsHook3
  ];
  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    gdk-pixbuf
    glib
    gtk3
    libGL
    libdrm
    libgbm
    libnotify
    libsecret
    libusb1
    libxkbcommon
    nspr
    nss
    openssl
    pango
    stdenv.cc.cc.lib
    systemd
    tpm2-tss
    wayland
    libX11
    libxcb
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
  ];
  runtimeDependencies = map lib.getLib [
    libGL
    libsecret
    libnotify
    systemd
    wayland
  ];

  unpackCmd = "dpkg-deb -x $curSrc .";
  sourceRoot = ".";
  postPatch = ''
    asar extract usr/lib/chatgpt/resources/app.asar app
    # Nix relocates the ELF interpreter beyond detect-libc's read buffer.
    # Avoid its crashing process.report fallback by providing the real ldd path.
    substituteInPlace app/node_modules/@parcel/watcher/node_modules/detect-libc/lib/filesystem.js \
      --replace-fail "'/usr/bin/ldd'" "'${lib.getBin glibc}/bin/ldd'"
    asar pack app usr/lib/chatgpt/resources/app.asar --unpack-dir node_modules
    rm -r app
  '';

  dontConfigure = true;
  dontBuild = true;
  dontWrapGApps = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib $out/share
    cp -r usr/lib/chatgpt $out/lib/chatgpt
    # Use GTK; the bundled Qt shims and musl variants are not used on this host.
    rm $out/lib/chatgpt/libqt{5,6}_shim.so
    find $out/lib/chatgpt/resources -name '*musl*' -exec rm -rf {} +
    cp -r usr/share/applications usr/share/pixmaps usr/share/metainfo $out/share/
    makeWrapper $out/lib/chatgpt/ChatGPT $out/bin/chatgpt \
      "''${gappsWrapperArgs[@]}" \
      --prefix PATH : ${lib.makeBinPath [ xdg-utils ]} \
      --add-flags "--ozone-platform=wayland" \
      ${lib.optionalString (deviceScaleFactor != null) ''--add-flags "--force-device-scale-factor=${deviceScaleFactor}"''}
    substituteInPlace $out/share/applications/chatgpt.desktop \
      --replace-fail "Exec=chatgpt %U" "Exec=$out/bin/chatgpt %U"
    runHook postInstall
  '';

  meta = {
    description = "Official ChatGPT desktop app with Codex";
    homepage = "https://learn.chatgpt.com/docs/linux/linux-app";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "chatgpt";
  };
})
