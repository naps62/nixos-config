{
  config,
  lib,
  pkgs,
  ...
}:
# User-space gaming toolkit. Vendor-agnostic on purpose so it can be reused on
# AMD/Intel hosts — the only GPU-vendor-aware branch is `cfg.nvidia`, kept
# deliberately small. The host still owns the privileged pieces (Steam FHS
# wrapper, Sunshine, gamemode, gamescope caps) under
# hosts/common/features/gaming.
#
# Per-host segregation is by option: a host imports this module and enables only
# the pieces it wants (e.g. a laptop enables `moonlight` for streaming without
# the full `enable` launcher/Proton toolkit).
let
  cfg = config.custom.gaming;
in
{
  imports = [
    ./moonlight.nix
    ./retroarch.nix
    ./sunshine-session-lock.nix
  ];

  options.custom.gaming = {
    enable = lib.mkEnableOption "user-space gaming tools (launchers, Proton mgmt, MangoHud)";

    nvidia = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Enable NVIDIA-specific extras (currently just nvtop). Keep this the only
        NVIDIA-aware branch in this file so the module stays reusable on other
        GPUs. NVENC streaming needs no user config — it comes from the host
        NVIDIA driver.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # NOTE: Steam itself is enabled at the host level (programs.steam) because it
    # needs the FHS wrapper, udev rules and 32-bit graphics — home-manager can't
    # provide those. See hosts/common/features/gaming/steam.nix.
    home.packages =
      with pkgs;
      [
        # launchers / stores
        lutris
        heroic # Epic / GOG / Amazon

        # Proton / Wine compatibility tooling
        protonplus # install & manage Proton-GE builds
        protontricks
        winetricks

        # overlays, tuning & diagnostics
        goverlay # GUI to configure MangoHud / vkBasalt
        vkbasalt # Vulkan post-processing layer
        vulkan-tools # vulkaninfo / vkcube for sanity checks
      ]
      ++ lib.optionals cfg.nvidia [
        nvtopPackages.nvidia # GPU/VRAM/encoder monitor
      ];

    # In-game performance overlay (toggle with Shift+F12 by default).
    programs.mangohud = {
      enable = true;
      settings = {
        fps_limit = 0;
        gpu_stats = true;
        gpu_temp = true;
        vram = true;
        cpu_stats = true;
        cpu_temp = true;
        ram = true;
        frametime = true;
        frame_timing = true;
      };
    };
  };
}
