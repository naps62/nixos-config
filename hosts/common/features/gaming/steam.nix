{ pkgs, ... }:

{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;

    # Steam's UI (store/library/Big Picture) is a Chromium/CEF app. On NVIDIA +
    # Wayland its GPU child process intermittently trips the CEF GPU sandbox and
    # crashes (cef_log: "GPU process exited unexpectedly: exit_code=8704");
    # Chromium then permanently falls back to CPU rendering for that session
    # (--disable-gpu), which turns Big Picture into a slideshow at our 4K/HiDPI
    # scale. Streaming (NVENC + game load hammering the GPU at once) is a common
    # trigger. -cef-disable-gpu-sandbox drops the sandbox around *only* Steam's
    # own UI renderer so the GPU process stops crashing and Big Picture stays
    # hardware-accelerated. extraArgs bakes it into `exec steam ... "$@"`, so it
    # applies to every entry point (desktop, CLI, Sunshine's Big Picture tile) —
    # launch flags only take effect on the invocation that first starts Steam.
    package = pkgs.steam.override { extraArgs = "-cef-disable-gpu-sandbox"; };
  };

  hardware.steam-hardware.enable = true;
}
