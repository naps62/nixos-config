{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  pi = pkgs.callPackage ../../../pkgs/pi/package.nix { };

  skills = inputs.agent-skills;

  # pi has no `@file` imports in context files, so fragments get concatenated
  # into one AGENTS.md. Skills need no wiring: pi reads ~/.agents/skills, which
  # the agent-skills module already links.
  agentsMd = pkgs.writeText "pi-AGENTS.md" (
    lib.concatMapStringsSep "\n" builtins.readFile [
      "${skills}/claude-md/machines/${config.programs.agentSkills.machine}.md"
      "${skills}/claude-md/operating.md"
      "${skills}/claude-md/writing.md"
      "${skills}/claude-md/code-comments.md"
      "${skills}/claude-md/RTK.md"
    ]
  );
in
{
  home.packages = [ pi ];

  # Settings stay unmanaged: pi writes ~/.pi/agent/settings.json itself from
  # /settings, /trust and `pi config`.
  home.file.".pi/agent/AGENTS.md".source = agentsMd;
}
