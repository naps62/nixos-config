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
  # GPU-accelerated local Whisper transcription + onnxruntime CUDA execution
  # provider (NVIDIA hosts only). The bundled onnxruntime-node binaries were
  # built against CUDA 13, so this must stay pinned to cudaPackages_13
  # regardless of nixpkgs' default cudaPackages version.
  cudaSupport ? false,
  cudaPackages_13,
}:

let
  # onnxruntime's CUDA execution provider wants these exact SONAMEs
  # (verified against the .so it ships: libcublas.so.13, libcudnn.so.9, etc).
  # libcuda.so.1 itself comes from the NVIDIA driver at /run/opengl-driver/lib
  # (runtime-only, never present in the build sandbox) — not part of this set.
  cudaLibs = lib.optionals cudaSupport (
    map lib.getLib (
      with cudaPackages_13;
      [
        cuda_cudart
        libcublas
        cudnn
        libcufft
        libcurand
        cuda_nvrtc
      ]
    )
  );
in
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
  ]
  ++ cudaLibs;

  # dlopen'd at runtime; make autoPatchelf bake them into the rpath.
  runtimeDependencies = [
    libappindicator
    libnotify
    libGL
    (lib.getLib systemd)
  ];

  # onnxruntime-node also bundles a TensorRT execution provider, but the app
  # only ever selects `cuda` or `vulkan` as a backend — TensorRT is dead
  # weight either way, not worth pulling in. libcuda.so.1 is the NVIDIA
  # driver's own lib, only present at /run/opengl-driver/lib on an activated
  # NixOS system, never inside the build sandbox — same story as libGL below.
  # The rest (cudart/cublas/cudnn/cufft/curand/nvrtc) are only ignored when
  # cudaSupport is off; otherwise cudaLibs above satisfies them for real.
  autoPatchelfIgnoreMissingDeps = [
    "libcuda.so.1"
    "libnvinfer.so.10"
    "libnvonnxparser.so.10"
  ]
  ++ lib.optionals (!cudaSupport) [
    "libcublas.so.13"
    "libcublasLt.so.13"
    "libcudart.so.13"
    "libcudnn.so.9"
    "libcufft.so.12"
    "libcurand.so.10"
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
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath ([
        # cudaLibs is also needed here, not just in buildInputs: OpenWhispr
        # downloads its own CUDA-accelerated whisper-server binary at
        # runtime, which never goes through autoPatchelf and only finds
        # these via the inherited environment.
        libGL
        mesa
      ] ++ cudaLibs)}:/run/opengl-driver/lib"

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
