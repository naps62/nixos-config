{
  config,
  pkgs,
  lib,
  ...
}:
let
  claude-desktop = pkgs.callPackage ../../../pkgs/claude-desktop/package.nix {
    inherit (config.custom.aiApps) deviceScaleFactor;
  };
  chatgpt = pkgs.callPackage ../../../pkgs/chatgpt/package.nix { };
  t3-code = pkgs.callPackage ../../../pkgs/t3-code/package.nix {
    inherit (config.custom.aiApps) deviceScaleFactor;
  };
  openwhispr = pkgs.callPackage ../../../pkgs/openwhispr/package.nix {
    inherit (config.custom.aiApps) deviceScaleFactor;
    cudaSupport = config.custom.aiApps.cudaAcceleration;
  };
in
{
  home.packages = lib.optionals pkgs.stdenv.hostPlatform.isx86_64 [
    claude-desktop
    chatgpt
    t3-code
    openwhispr
  ];
}
