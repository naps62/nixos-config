{
  inputs,
  pkgs,
  ...
}:
let
  codex-cli = inputs.codex-cli.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  imports = [ inputs.codex-desktop-linux.homeManagerModules.default ];

  programs.codexDesktopLinux = {
    enable = true;
    cliPackage = codex-cli;
  };
}
