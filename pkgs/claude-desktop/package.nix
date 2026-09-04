{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  dpkg,
  makeWrapper,
  wrapGAppsHook3,
  # runtime / autopatchelf libs
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
  libcap_ng,
  libGL,
  libdrm,
  libnotify,
  libseccomp,
  libsecret,
  libuuid,
  libxkbcommon,
  mesa,
  nspr,
  nss,
  pango,
  systemd,
  xdg-utils,
  libX11,
  libxcb,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxkbfile,
  libxrandr,
  libxscrnsaver,
  libxshmfence,
  libxtst,
  # UI scaling: null = native, or a string like "1.5" for --force-device-scale-factor.
  deviceScaleFactor ? null,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "claude-desktop";
  version = "1.21459.3";

  # Official Anthropic Linux build, pulled straight from their apt pool.
  # To bump: find the newest entry in
  #   https://downloads.claude.ai/claude-desktop/apt/stable/dists/stable/main/binary-amd64/Packages
  # then update version + hash (nix hash convert --to sri the listed SHA256).
  src = fetchurl {
    url = "https://downloads.claude.ai/claude-desktop/apt/stable/pool/main/c/claude-desktop/claude-desktop_${finalAttrs.version}_amd64.deb";
    hash = "sha256-My0k7439p83WM+9iTvM1zrMatUtHHijXhavGAWrmqb4=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
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
    libcap_ng
    libGL
    libdrm
    libnotify
    libseccomp
    libsecret
    libuuid
    libxkbcommon
    mesa
    nspr
    nss
    pango
    stdenv.cc.cc.lib
    systemd
    libX11
    libxcb
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxkbfile
    libxrandr
    libxscrnsaver
    libxshmfence
    libxtst
  ];

  # dlopen'd at runtime; make autoPatchelf bake them into the rpath.
  runtimeDependencies = [
    libnotify
    libGL
    (lib.getLib systemd)
  ];

  unpackCmd = "dpkg-deb -x $curSrc .";
  sourceRoot = ".";

  dontConfigure = true;
  dontBuild = true;
  # gappsWrapperArgs feed into the makeWrapper call below.
  dontWrapGApps = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r usr/lib $out/lib
    cp -r usr/share $out/share

    # chrome-sandbox needs setuid-root, which the nix store can't provide.
    # Disable the SUID sandbox and rely on user namespaces instead.
    # The bundled Chromium/ANGLE dlopen()s the system libEGL.so.1 for GL; give it
    # libglvnd + NixOS's GPU driver path so it hardware-accelerates instead of
    # falling back to software rendering.
    # Chromium maps XDG_CURRENT_DESKTOP=Hyprland to "other" and silently picks the
    # plaintext `basic` keystore, so safeStorage reports unavailable and auth tokens
    # never persist across restarts. Pin the libsecret backend explicitly.
    makeWrapper $out/lib/claude-desktop/claude-desktop $out/bin/claude-desktop \
      "''${gappsWrapperArgs[@]}" \
      --add-flags "--no-sandbox --password-store=gnome-libsecret${lib.optionalString (deviceScaleFactor != null) " --force-device-scale-factor=${deviceScaleFactor}"}" \
      --prefix PATH : ${lib.makeBinPath [ xdg-utils ]} \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ libGL mesa ]}:/run/opengl-driver/lib"

    # Point the .desktop Exec/Icon at our wrapper (names already match).
    substituteInPlace $out/share/applications/com.anthropic.Claude.desktop \
      --replace-fail "Exec=claude-desktop" "Exec=$out/bin/claude-desktop"

    runHook postInstall
  '';

  meta = {
    description = "Desktop application for Claude.ai (official Linux build)";
    homepage = "https://claude.ai";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "claude-desktop";
  };
})
