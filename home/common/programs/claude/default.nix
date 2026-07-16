{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
let
  # Official Anthropic Claude desktop app (Linux build, x86_64 only).
  claude-desktop = pkgs.callPackage ../../../../pkgs/claude-desktop/package.nix {
    inherit (config.custom.aiApps) deviceScaleFactor;
  };
in
{
  # Shared UI-scale knob for the Electron AI desktop apps (Claude Desktop, T3 Code).
  # Set per-host (e.g. konishi's 4K@1x monitors want ~"1.5"); null = native scale.
  options.custom.aiApps.deviceScaleFactor = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    example = "1.5";
    description = "--force-device-scale-factor value for Claude Desktop and T3 Code.";
  };

  config.home = {
    packages =
      with pkgs;
      [
        inputs.claude-code.packages.${pkgs.stdenv.hostPlatform.system}.default

        # sandbox
        bubblewrap
        socat
        libseccomp

        # voice
        sox

        # beads
        dolt
      ]
      ++ lib.optional pkgs.stdenv.hostPlatform.isx86_64 claude-desktop;

    file = {
      ".default-npm-packages".text = ''
        @anthropic-ai/sandbox-runtime
        @beads/bd
      '';

      # Commands
      ".claude/commands/merge.md".source = ./commands/merge.md;
      ".claude/commands/update.md".source = ./commands/update.md;
      ".claude/commands/download-playlist.md".source = ./commands/download-playlist.md;

      # Skills: agents
      ".claude/skills/designer-bold/SKILL.md".source = ./skills/designer-bold/SKILL.md;
      ".claude/skills/designer/SKILL.md".source = ./skills/designer/SKILL.md;
      ".claude/skills/frontend-design/SKILL.md".source = ./skills/frontend-design/SKILL.md;
      ".claude/skills/analyze-branch/SKILL.md".source = ./skills/analyze-branch/SKILL.md;
      ".claude/skills/oracle/SKILL.md".source = ./skills/oracle/SKILL.md;
      ".claude/skills/librarian/SKILL.md".source = ./skills/librarian/SKILL.md;

      # Skills: knowledge
      ".claude/skills/git-master/SKILL.md".source = ./skills/git-master/SKILL.md;
      ".claude/skills/planning-with-files/SKILL.md".source =
        ./skills/planning-with-files/SKILL.md;
      ".claude/skills/react-patterns/SKILL.md".source = ./skills/react-patterns/SKILL.md;
      ".claude/skills/vercel-react-best-practices/SKILL.md".source =
        ./skills/vercel-react-best-practices/SKILL.md;

      # Skills: workflows
      ".claude/skills/smart-debug/SKILL.md".source = ./skills/smart-debug/SKILL.md;
      ".claude/skills/tdd-cycle/SKILL.md".source = ./skills/tdd-cycle/SKILL.md;
      ".claude/skills/security-scan/SKILL.md".source = ./skills/security-scan/SKILL.md;
      ".claude/skills/issue/SKILL.md".source = ./skills/issue/SKILL.md;
      ".claude/skills/remove-deadcode/SKILL.md".source = ./skills/remove-deadcode/SKILL.md;
      ".claude/skills/worktree-compare/SKILL.md".source = ./skills/worktree-compare/SKILL.md;
      ".claude/skills/worktree-list/SKILL.md".source = ./skills/worktree-list/SKILL.md;

      # Skills: linear workflow
      ".claude/skills/linear-common/COMMON.md".source = ./skills/linear-common/COMMON.md;
      ".claude/skills/work/SKILL.md".source = ./skills/work/SKILL.md;
      ".claude/skills/yolo/SKILL.md".source = ./skills/yolo/SKILL.md;

      ".claude/statusline.sh" = {
        source = ./statusline.sh;
        executable = true;
      };
      ".claude/CLAUDE.md".source = ./CLAUDE.md;
    };

    mutableFiles.".claude/settings.json".source = ./settings.json;
  };
}
