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
  libappindicator,
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
  pipewire,
  systemd,
  zlib,
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
  # external tools OpenWhispr shells out to for global hotkey / paste
  ydotool,
  wl-clipboard,
  xclip,
  xdotool,
  wtype,
  xsel,
  # UI scaling: null = native, or a string like "1.5" for --force-device-scale-factor.
  deviceScaleFactor ? null,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "openwhispr";
  version = "1.9.2";

  # Official upstream Linux build, pulled straight from the GitHub release.
  # To bump: check https://github.com/OpenWhispr/openwhispr/releases for the
  # newest tag, then update version + hash (nix-prefetch-url --type sha256 <url>).
  src = fetchurl {
    url = "https://github.com/OpenWhispr/openwhispr/releases/download/v${finalAttrs.version}/OpenWhispr-${finalAttrs.version}-linux-amd64.deb";
    hash = "sha256-7wTM2yUvTXAYtomToeiyUv4BCjdBuf4VgaUhRZON4XU=";
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
    pipewire
    stdenv.cc.cc.lib
    systemd
    zlib
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
    libappindicator
    libnotify
    libGL
    (lib.getLib systemd)
  ];

  # onnxruntime-node bundles CUDA/TensorRT execution providers it only
  # dlopen()s if explicitly requested; falls back to the CPU provider
  # (already patched fine) without them. Packaging full CUDA+cuDNN+TensorRT
  # just to satisfy autoPatchelf here isn't worth it.
  autoPatchelfIgnoreMissingDeps = [
    "libcublas.so.13"
    "libcublasLt.so.13"
    "libcuda.so.1"
    "libcudart.so.13"
    "libcudnn.so.9"
    "libcufft.so.12"
    "libcurand.so.10"
    "libnvinfer.so.10"
    "libnvonnxparser.so.10"
    "libnvrtc.so.13"
  ];

  unpackCmd = "dpkg-deb -x $curSrc .";
  sourceRoot = ".";

  dontConfigure = true;
  dontBuild = true;
  # gappsWrapperArgs feed into the makeWrapper call below.
  dontWrapGApps = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib
    cp -r opt/OpenWhispr $out/lib/openwhispr
    cp -r usr/share $out/share

    # The bundled open-whispr launcher already falls back to --no-sandbox when
    # unprivileged user namespaces aren't available (chrome-sandbox can't be
    # setuid-root out of the nix store); nothing extra needed for that here.
    # ydotool/wl-clipboard etc. are the global-hotkey/paste backends OpenWhispr
    # shells out to; ydotoold itself still needs `programs.ydotool.enable` at
    # the NixOS level for the /dev/uinput access.
    deviceScaleFlags=()
    ${lib.optionalString (
      deviceScaleFactor != null
    ) ''deviceScaleFlags=(--add-flags "--force-device-scale-factor=${deviceScaleFactor}")''}

    makeWrapper $out/lib/openwhispr/open-whispr $out/bin/openwhispr \
      "''${gappsWrapperArgs[@]}" \
      "''${deviceScaleFlags[@]}" \
      --prefix PATH : ${
        lib.makeBinPath [
          ydotool
          wl-clipboard
          xclip
          xdotool
          wtype
          xsel
        ]
      } \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ libGL mesa ]}:/run/opengl-driver/lib"

    substituteInPlace $out/share/applications/open-whispr.desktop \
      --replace-fail "Exec=/opt/OpenWhispr/open-whispr %U" "Exec=$out/bin/openwhispr %U"

    runHook postInstall
  '';

  meta = {
    description = "Voice-to-text dictation app with local (Whisper/Parakeet) and cloud transcription models";
    homepage = "https://github.com/OpenWhispr/openwhispr";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "openwhispr";
  };
})
