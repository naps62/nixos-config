{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
let
  claude-desktop = pkgs.callPackage ../../../pkgs/claude-desktop/package.nix {
    inherit (config.custom.aiApps) deviceScaleFactor;
  };
  codex-cli = inputs.codex-cli.packages.${pkgs.stdenv.hostPlatform.system}.default;
  t3-code = pkgs.callPackage ../../../pkgs/t3-code/package.nix {
    inherit (config.custom.aiApps) deviceScaleFactor;
  };
  openwhispr = pkgs.callPackage ../../../pkgs/openwhispr/package.nix {
    inherit (config.custom.aiApps) deviceScaleFactor;
    cudaSupport = config.custom.aiApps.cudaAcceleration;
  };
in
{
  imports = [ inputs.codex-desktop-linux.homeManagerModules.default ];

  home.packages = lib.optionals pkgs.stdenv.hostPlatform.isx86_64 [
    claude-desktop
    t3-code
    openwhispr
  ];

  programs.codexDesktopLinux = {
    enable = true;
    cliPackage = codex-cli;
  };
}
