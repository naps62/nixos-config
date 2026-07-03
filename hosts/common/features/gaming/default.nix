{ ... }:
# Host-level gaming stack: the privileged pieces that home-manager can't
# provide. GPU-vendor-agnostic — NVIDIA/Intel/AMD drivers come from the host's
# gpu/* module. Pair this with the user-space toolkit in
# home/common/programs/gaming.nix (custom.gaming).
{
  imports = [
    ./steam.nix
    ./sunshine.nix
  ];

  # Feral gamemode: games (and Lutris/Steam launch options) can request a
  # CPU-governor / scheduling boost via `gamemoderun %command%`.
  programs.gamemode.enable = true;

  # Micro-compositor used for tear-free, frame-paced output and upscaling.
  # capSysNice lets it use realtime scheduling (`--rt`), which also helps the
  # Sunshine capture path stay smooth.
  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };
}
