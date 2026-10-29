{
  lib,
  sunshine,
  fetchFromGitHub,
  fetchzip,
  buildNpmPackage,
  runCommand,
  boost,
  sysprof,
  cudaSupport ? true,
}:
# Vibepollo (Nonary's Sunshine/Apollo fork) built by reusing nixpkgs' sunshine
# recipe. Only the host binary: the Linux beta's DKMS virtual-display driver
# and pacman packaging are not reproduced, and upstream only supports KDE
# Plasma, so capture on Hyprland is an experiment.
let
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "Nonary";
    repo = "Vibepollo";
    rev = "66e169c325dab73e4e780fe34ac3c613af4cdf52"; # 2.0.1
    hash = "sha256-IvF8ymspdBHnQohWEmTe5BBOqf/U6fO/06UmhhQQ2DY=";
    fetchSubmodules = true;
  };

  # The third-party/build-deps submodule pins this tag.
  ffmpegPrebuilt = fetchzip {
    url = "https://github.com/LizardByte/build-deps/releases/download/v2026.516.30821/Linux-x86_64-ffmpeg.tar.gz";
    hash = "sha256-VT+4qP2FaizCoIBBbBkzbYw4YOvGhuBUoZxWL0IYVZo=";
  };

  webSub = "src_assets/common/assets/web";
  legacySub = "src_assets/common/assets/web-legacy";

  mkUi =
    { name, sub, outVar, npmDepsHash, build ? "npm run build" }:
    buildNpmPackage {
      pname = "vibepollo-${name}";
      inherit version src npmDepsHash;
      sourceRoot = "${src.name}/${sub}";
      npmFlags = [ "--ignore-scripts" ];
      dontNpmBuild = true;
      buildPhase = ''
        runHook preBuild
        export ${outVar}=$PWD/dist
        ${build}
        runHook postBuild
      '';
      installPhase = ''
        runHook preInstall
        cp -r dist $out
        runHook postInstall
      '';
    };

  uiV2 = mkUi {
    name = "ui";
    sub = webSub;
    outVar = "SUNSHINE_WEB_OUTPUT_DIR";
    build = "npm run tokens && npx vite build";
    npmDepsHash = "sha256-QBFQRhp6QFJZgOU2mQNj/yGA+mZm0wF7GRDgeVP4olA=";
  };

  uiLegacy = mkUi {
    name = "ui-legacy";
    sub = legacySub;
    outVar = "SUNSHINE_LEGACY_WEB_OUTPUT_DIR";
    npmDepsHash = "sha256-xTh4IcoX1LKUIhUKMcZW/32Zm3alx04DFOGElP322uw=";
  };

  assets = runCommand "vibepollo-web-assets" { } ''
    mkdir -p $out/assets
    cp -r ${uiLegacy} $out/assets/web
    chmod -R u+w $out/assets/web
    cp -r ${uiV2} $out/assets/web/v2
  '';
in
(sunshine.override { inherit cudaSupport; }).overrideAttrs (old: {
  pname = "vibepollo";
  inherit version src;

  # Replace the inherited root-level npm build; see preBuild.
  ui = assets;

  # The upstream web.cmake shells out to npm; we prebuild the UI instead.
  postPatch = ''
    cat > cmake/targets/web.cmake <<'CMAKE'
    add_custom_target(web_ui)
    CMAKE

    sed -i -E 's/set\(BOOST_VERSION "[^"]*"\)/set(BOOST_VERSION "${boost.version}")/' \
      cmake/dependencies/Boost_Sunshine.cmake
    echo 'set(FETCH_CONTENT_BOOST_USED TRUE)' >> cmake/dependencies/Boost_Sunshine.cmake
    # boost 1.91 ships no boost_system CMake component (header-only now)
    sed -i '/^        system$/d' cmake/dependencies/Boost_Sunshine.cmake

    substituteInPlace cmake/packaging/linux.cmake \
      --replace-fail 'find_package(Systemd)' "" \
      --replace-fail 'find_package(Udev)' ""
  '';

  cmakeFlags = [
    (lib.cmakeBool "BUILD_TESTS" false)
    (lib.cmakeBool "SUNSHINE_ENABLE_TRAY" false)
    (lib.cmakeFeature "SUNSHINE_ASSETS_DIR" "share/vibepollo")
  ] ++ map (
    f:
    if lib.hasPrefix "-DFFMPEG_PREPARED_BINARIES" f then
      lib.cmakeFeature "FFMPEG_PREPARED_BINARIES" "${ffmpegPrebuilt}"
    else
      f
  ) old.cmakeFlags;

  preBuild = ''
    mkdir -p assets
    cp -r --no-preserve=mode ${assets}/assets/web assets/web
  '';

  # Skip `cmake --install`: its Linux rules install the pacman/DKMS packaging.
  installPhase = ''
    runHook preInstall
    install -Dm755 vibepollo $out/bin/vibepollo
    mkdir -p $out/share/vibepollo
    cp -r --no-preserve=mode ../src_assets/common/assets/. $out/share/vibepollo/
    rm -rf $out/share/vibepollo/web $out/share/vibepollo/web-legacy
    cp -r --no-preserve=mode ../src_assets/linux/assets/. $out/share/vibepollo/
    cp -r --no-preserve=mode ${assets}/assets/web $out/share/vibepollo/web
    runHook postInstall
  '';

  postFixup = builtins.replaceStrings [ "bin/sunshine" ] [ "bin/vibepollo" ] old.postFixup;

  buildInputs = old.buildInputs ++ [ sysprof ];

  passthru = old.passthru // { inherit uiV2 uiLegacy; };
  meta = old.meta // {
    description = "Sunshine/Apollo fork with virtual displays and Playnite integration";
    homepage = "https://github.com/Nonary/Vibepollo";
  };
})
