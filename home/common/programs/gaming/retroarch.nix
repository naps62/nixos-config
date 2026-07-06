{
  config,
  lib,
  pkgs,
  ...
}:
# RetroArch — libretro frontend/emulator, plus standalone Dolphin & PCSX2.
#
# Cores are managed declaratively through `retroarch.withCores`. The in-app
# Online Updater / Core Downloader is compiled out of the nixpkgs build
# (--disable-update_cores), and the libretro buildbot cores wouldn't run on
# NixOS anyway (generic-Linux binaries linked against FHS paths). So cores come
# from nixpkgs' `libretro.*` set and are baked into the wrapper — add or drop a
# system by editing the list below.
#
# ROMs and BIOS/firmware are still supplied by hand:
#   * roms   -> ~/roms                      (game files)
#   * system -> ~/.config/retroarch/system  (BIOS dumps: PS1, Saturn, DS, CD, …)
# Both are seeded as empty writable dirs via `.keep` placeholders, so
# home-manager creates the trees without owning their contents.
#
# GameCube/Wii and PS2 are installed as the standalone emulators (dolphin-emu,
# pcsx2) rather than libretro cores — those cores exist but the standalones are
# far better maintained and less finicky.
#
# WebDAV cloud sync is configured in the RetroArch UI (Settings > Cloud Sync):
# no server URL or credentials live in this repo, since there's no secrets
# tooling here and the Nix store is world-readable.
#
# Gated by its own option, independent of `custom.gaming.enable`, matching the
# moonlight module next door.
let
  cfg = config.custom.gaming;
in
{
  options.custom.gaming.retroarch = lib.mkEnableOption "RetroArch (declarative cores) + standalone Dolphin/PCSX2";

  config = lib.mkIf cfg.retroarch {
    home.packages = [
      (pkgs.retroarch.withCores (
        cores: with cores; [
          # Nintendo
          mesen # NES
          snes9x # SNES
          gambatte # Game Boy / Color
          mgba # GBA
          mupen64plus # N64 (Mupen64Plus-Next)
          melondsds # DS

          # Sega
          genesis-plus-gx # SMS / GG / Genesis / Mega Drive / Sega CD / SG-1000
          picodrive # 32X
          beetle-saturn # Saturn
          flycast # Dreamcast / NAOMI

          # Sony
          beetle-psx-hw # PS1 (HW upscaling)
          ppsspp # PSP

          # Handhelds / misc
          beetle-pce # PC Engine / TurboGrafx / CD
          beetle-wswan # WonderSwan
          beetle-ngp # Neo Geo Pocket
          beetle-lynx # Atari Lynx
          beetle-vb # Virtual Boy

          # Arcade
          fbneo # FinalBurn Neo
        ]
      ))

      # Better as standalones than their libretro cores:
      pkgs.dolphin-emu # GameCube / Wii
      pkgs.pcsx2 # PS2
    ];

    home.file."roms/.keep".text = "";
    xdg.configFile."retroarch/system/.keep".text = "";
  };
}
