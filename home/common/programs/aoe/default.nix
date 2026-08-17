{
  pkgs,
  inputs,
  ...
}:
# Agent of Empires: the agent session manager. The package only — settings are
# per-host, because config.toml carries `yolo_mode_default`, which decides
# whether sessions start with permission checks skipped.
{
  # aoe-with-web, not default: same single `aoe` binary plus the `serve`
  # subcommand (web dashboard). The default build has no `serve` at all.
  home.packages = [ inputs.agent-of-empires.packages.${pkgs.system}.aoe-with-web ];

  home.shellAliases.a = "aoe";
}
