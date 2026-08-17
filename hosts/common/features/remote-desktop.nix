_:
# Sunshine as a remote desktop. Same wlr-screencopy capture as
# features/gaming/sunshine.nix, minus its NVIDIA workarounds: no cudaSupport
# (virtio-gpu has no NVENC, so this software-encodes) and no uhid rule.
#
# First run: https://<host>:47990 to set web-UI credentials, then pair Moonlight.
{
  services.sunshine = {
    enable = true;
    autoStart = true;
    openFirewall = true;
    capSysAdmin = false; # wlr-screencopy needs no CAP_SYS_ADMIN

    settings = {
      # MUST be set. Auto-probe tries portalgrab first, and
      # xdg-desktop-portal-hyprland implements no RemoteDesktop interface — the
      # probe then hangs forever instead of falling back, so sunshine never
      # binds its ports and the unit sits "active" doing nothing.
      capture = "wlgrab";

      # The web UI is only reachable over the network here — there is no local
      # browser — and sunshine CSRF-rejects any origin but localhost unless it
      # is listed. Both addresses: .250.1 now, .10.2 after the IP handover.
      #
      # Bare comma-separated, NOT a JSON array: sunshine splits this on commas
      # and never strips brackets or quotes, so "[...]" makes every entry fail
      # its starts_with("https://") check.
      csrf_allowed_origins = "https://10.7.250.1:47990,https://10.7.10.2:47990";
    };
  };
}
