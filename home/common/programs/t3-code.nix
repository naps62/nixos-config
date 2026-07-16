{
  config,
  pkgs,
  lib,
  ...
}:
let
  # T3 Code: open-source desktop control plane for coding agents (x86_64 only).
  # Shares the custom.aiApps.deviceScaleFactor knob (defined in ../claude).
  t3-code = pkgs.callPackage ../../../pkgs/t3-code/package.nix {
    inherit (config.custom.aiApps) deviceScaleFactor;
  };
in
{
  home.packages = lib.optional pkgs.stdenv.hostPlatform.isx86_64 t3-code;
}
