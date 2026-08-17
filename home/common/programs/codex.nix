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

  # cliPackage only tells the desktop app where to find codex; it does not put
  # it on PATH, so the cli needs installing separately.
  home.packages = [ codex-cli ];

  programs.codexDesktopLinux = {
    enable = true;
    cliPackage = codex-cli;
  };
}
