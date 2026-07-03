{ ... }:
# Sunshine — self-hosted game-stream host for Moonlight clients (the NVIDIA
# Shield runs Moonlight). This is host-level because it needs root-owned bits:
# a setcap wrapper for display capture, /dev/uinput for virtual gamepad/mouse,
# and firewall ports.
#
# Encoding: on this host the RTX 4060's NVENC is picked up automatically from
# the NVIDIA driver (hosts/common/features/gpu/nvidia.nix) — no config needed.
# On an AMD/Intel host Sunshine would fall back to VAAPI; nothing here is
# NVIDIA-specific, so this module is reusable as-is.
#
# First run: open https://<host>:47990 to set the web-UI credentials, then pair
# the Shield (enter the PIN Moonlight shows). Moonlight discovers the host via
# Sunshine's built-in mDNS, so no separate avahi service is required.
{
  services.sunshine = {
    enable = true;
    autoStart = true; # start with the graphical session
    openFirewall = true; # 47984-48010 TCP + 47998-48010 UDP for Moonlight
    # Required to capture the display under Wayland/KMS (Hyprland). Grants the
    # setcap'd wrapper CAP_SYS_ADMIN.
    capSysAdmin = true;
  };
}
