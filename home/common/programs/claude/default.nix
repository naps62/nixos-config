{
  pkgs,
  inputs,
  lib,
  ...
}:
{
  imports = [
    inputs.agent-skills.homeModules.default
    ./synthetic.nix
  ];

  # Shared UI-scale knob for the Electron AI desktop apps (Claude Desktop, T3 Code).
  # Set per-host (e.g. konishi's 4K@1x monitors want ~"1.5"); null = native scale.
  options.custom.aiApps.deviceScaleFactor = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    example = "1.5";
    description = "--force-device-scale-factor value for Claude Desktop and T3 Code.";
  };

  # ~/.claude/settings.json stays unmanaged: Claude Code rewrites it itself
  # (model pins, permission grants, plugin state), so any nix copy drifts within
  # a session and every `nh home switch` then aborts on the diff.
  config.home = {
    packages = with pkgs; [
      inputs.claude-code.packages.${pkgs.stdenv.hostPlatform.system}.default

      # sandbox
      bubblewrap
      socat
      libseccomp

      # voice
      sox

      # beads
      dolt
    ];

    file = {
      ".default-npm-packages".text = ''
        @anthropic-ai/sandbox-runtime
        @beads/bd
      '';

      ".claude/statusline.sh" = {
        source = ./statusline.sh;
        executable = true;
      };
    };

  };
}
