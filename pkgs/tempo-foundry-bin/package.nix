{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  zlib,
  libgcc,
}:

let
  # Latest nightly as of 2026-02-11
  version = "nightly-ff2dc8bdde83aaefb4abaf73b7ac27059edeef25";

  # Platform-specific binary selection
  sources = {
    x86_64-linux = {
      url = "https://github.com/tempoxyz/tempo-foundry/releases/download/${version}/foundry_nightly_linux_amd64.tar.gz";
      hash = "sha256-0zpZpHEJ8m0YD0C4VqmFqmdneJHKjATawJO6fu5b6Og=";
    };
    aarch64-linux = {
      url = "https://github.com/tempoxyz/tempo-foundry/releases/download/${version}/foundry_nightly_linux_arm64.tar.gz";
      hash = lib.fakeSha256; # Update if building on aarch64-linux
    };
    x86_64-darwin = {
      url = "https://github.com/tempoxyz/tempo-foundry/releases/download/${version}/foundry_nightly_darwin_amd64.tar.gz";
      hash = lib.fakeSha256; # Update if building on darwin
    };
    aarch64-darwin = {
      url = "https://github.com/tempoxyz/tempo-foundry/releases/download/${version}/foundry_nightly_darwin_arm64.tar.gz";
      hash = lib.fakeSha256; # Update if building on darwin
    };
  };

  platform = sources.${stdenv.hostPlatform.system} or (throw "Unsupported platform: ${stdenv.hostPlatform.system}");
in

stdenv.mkDerivation {
  pname = "tempo-foundry-bin";
  inherit version;

  src = fetchurl {
    inherit (platform) url hash;
  };

  nativeBuildInputs = lib.optionals stdenv.isLinux [ autoPatchelfHook ];

  buildInputs = lib.optionals stdenv.isLinux [
    zlib
    libgcc
  ];

  dontBuild = true;
  dontConfigure = true;

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin

    # Install binaries (Tempo fork includes forge, cast, anvil, chisel)
    for bin in forge cast anvil chisel; do
      if [ -f "$bin" ]; then
        install -m755 -D "$bin" "$out/bin/$bin"
      fi
    done

    runHook postInstall
  '';

  meta = {
    description = "Tempo's fork of Foundry - portable and modular toolkit for Ethereum development with Tempo protocol features";
    homepage = "https://github.com/tempoxyz/tempo-foundry";
    license = with lib.licenses; [ mit asl20 ];
    maintainers = [ ];
    platforms = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    mainProgram = "forge";
  };
}
