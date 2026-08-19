{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  stdenv,
}:
let
  version = "0.84.2";

  # Prebuilt Bun executables from the release page. Bump version + hashes from
  # the SHA256SUMS asset:
  #   https://github.com/earendil-works/pi/releases
  sources = {
    x86_64-linux = {
      asset = "pi-linux-x64.tar.gz";
      hash = "sha256-kG++eH/SJcSsYk/n69Wx1Vpg4PXH71F5XSMVZPnuHBM=";
    };
    aarch64-linux = {
      asset = "pi-linux-arm64.tar.gz";
      hash = "sha256-0VNy2p5LTF/vn9Fb7XbX9fFyDdOf583g7GLltlrWPvE=";
    };
  };

  source =
    sources.${stdenvNoCC.hostPlatform.system}
      or (throw "pi: unsupported system ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "pi";
  inherit version;

  src = fetchurl {
    url = "https://github.com/earendil-works/pi/releases/download/v${version}/${source.asset}";
    inherit (source) hash;
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  # libgcc, for the bundled native clipboard module.
  buildInputs = [ (lib.getLib stdenv.cc.cc) ];

  installPhase = ''
    runHook preInstall

    # The binary resolves its themes, bundled node_modules and wasm relative to
    # itself, so the whole tree ships together and only `pi` gets a wrapper.
    mkdir -p $out/share/pi
    cp -r . $out/share/pi/
    chmod +x $out/share/pi/pi

    # Nix owns updates here; `pi update --self` would write into the store.
    makeWrapper $out/share/pi/pi $out/bin/pi \
      --set-default PI_SKIP_VERSION_CHECK 1

    runHook postInstall
  '';

  meta = {
    description = "Pi coding agent CLI";
    homepage = "https://pi.dev";
    changelog = "https://github.com/earendil-works/pi/releases/tag/v${version}";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = lib.attrNames sources;
    mainProgram = "pi";
  };
}
