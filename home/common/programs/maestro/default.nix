{ inputs, ... }:
# Maestro: the terminal-session orchestrator. Module only — no `enable` here,
# because the daemon owns every interactive shell on the host it runs on, and
# only one box should be doing that. Hosts opt in from their own services.nix.
{
  imports = [ inputs.maestro.homeManagerModules.default ];
}
