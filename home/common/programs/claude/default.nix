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






      ".claude/statusline.sh" = {
        source = ./statusline.sh;
        executable = true;
      };
    };

    mutableFiles.".claude/settings.json".source = ./settings.json;
  };
}
