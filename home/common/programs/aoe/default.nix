{
  pkgs,
  inputs,
  ...
}:
# Agent of Empires: the agent session manager. Import this on any host that
# wants it — it brings both the package and the shared settings.
{
  home.packages = [ inputs.agent-of-empires.packages.${pkgs.system}.default ];

  # mutableFiles, not xdg.configFile: aoe rewrites this file itself (it keeps
  # .bak-<epoch> copies), so a read-only store symlink would break it. The copy
  # is change-detected — activation aborts and tells you to bring edits back
  # here rather than silently reverting them.
  #
  # Only config.toml. The rest of ~/.config/agent-of-empires is per-machine
  # state (state.toml, projects.json, tui-*, locks) or secret
  # (serve.saved_passphrase).
  home.mutableFiles.".config/agent-of-empires/config.toml".source = ./config.toml;
}
