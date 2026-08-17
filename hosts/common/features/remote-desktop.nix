_:
# Sunshine as a remote desktop. Same wlr-screencopy capture as
# features/gaming/sunshine.nix, minus its NVIDIA workarounds: no cudaSupport
# (virtio-gpu has no NVENC, so this software-encodes) and no uhid rule.
#
# First run: https://<host>:47990 to set web-UI credentials, then pair Moonlight.
{
  # Sunshine opens /dev/dri/renderD* once per encoder probe and never closes
  # them — ~973 fds against the 1024 default. Mesa then cannot dlopen the GBM
  # driver ("Too many open files"), capture falls back to a broken path, and
  # moonlight shows a black, artefacted picture rather than any error.
  systemd.user.services.sunshine.serviceConfig.LimitNOFILE = 65536;

  services.sunshine = {
    enable = true;
    autoStart = true;
    openFirewall = true;
    capSysAdmin = true; # kms capture reads the scanout framebuffer via DRM

    settings = {
      # MUST be set. Auto-probe tries portalgrab first, and
      # xdg-desktop-portal-hyprland implements no RemoteDesktop interface — the
      # probe then hangs forever instead of falling back, so sunshine never
      # binds its ports and the unit sits "active" doing nothing.
      #
      # "kms", not "wlr": the wlr backend takes wlr-screencopy's dmabuf path,
      # which on this virtio-gpu returns empty buffers — sunshine encodes a flat
      # frame (~50-byte P-frames) and every client shows black, with no error on
      # either side. grim still works because it uses the shm path, and sunshine
      # exposes no way to force shm.
      #
      # "wlr", not "wlgrab": wlgrab is the name that backend logs under, but it
      # is not accepted as a value — sunshine rejects it with "Unable to
      # initialize capture method", then still starts and binds its ports with
      # no encoder, so the failure only shows up as a 503 in moonlight.
      capture = "kms";

      # The web UI is only reachable over the network here — there is no local
      # browser — and sunshine CSRF-rejects any origin but localhost unless it
      # is listed. Both addresses: .250.1 now, .10.2 after the IP handover.
      #
      # Bare comma-separated, NOT a JSON array: sunshine splits this on commas
      # and never strips brackets or quotes, so "[...]" makes every entry fail
      # its starts_with("https://") check.
      csrf_allowed_origins = "https://10.7.250.1:47990,https://10.7.10.2:47990";

      # At the default 20, sunshine's FEC mangles large frames and moonlight
      # draws horizontal bands over an otherwise-fine stream — no error on
      # either side, and the network shows 0% loss. konishi carries the same
      # workaround in its hand-written ~/.config/sunshine/sunshine.conf.
      fec_percentage = 1;
    };
  };
}
