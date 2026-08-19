{ pkgs, ... }:
let
  pi = pkgs.callPackage ../../../pkgs/pi/package.nix { };
in
{
  # ~/.pi/agent/AGENTS.md comes from the agent-skills home-manager module
  # (pi has no @file imports, so the module concatenates the shared fragments).
  # Pi reads skills straight from ~/.agents/skills, which the module links.
  # Settings stay unmanaged: pi writes ~/.pi/agent/settings.json itself from
  # /settings, /trust and `pi config`.
  home.packages = [ pi ];
}
