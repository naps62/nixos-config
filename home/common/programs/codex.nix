{
  inputs,
  pkgs,
  ...
}:
let
  codex-cli = inputs.codex-cli.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  home.packages = [ codex-cli ];
}
