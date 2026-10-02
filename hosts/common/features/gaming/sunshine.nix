{
  config,
  lib,
  pkgs,
  ...
}:
# Sunshine — self-hosted game-stream host for Moonlight clients (the NVIDIA
# Shield runs Moonlight). Host-level because it needs root-owned bits: display
# capture, /dev/uinput for virtual gamepad/mouse, and firewall ports.
#
# Hardware (NVENC) encoding on this box needs two things that the stock
# nixpkgs setup doesn't give you:
#
#   1. A CUDA-enabled Sunshine. The default build is compiled with
#      -DSUNSHINE_ENABLE_CUDA=FALSE, so it has the NVENC *encoders* but no CUDA
#      frame-scaling/colour-conversion path — every NVENC probe dies with
#      "Couldn't scale frame: Invalid argument" and it silently falls back to
#      CPU x264. `cudaSupport = true` rebuilds it with CUDA.
#
#   2. libcuda.so.1 discoverable at runtime. It lives in /run/opengl-driver/lib
#      (NVIDIA driver), which isn't on Sunshine's default library path, so we
#      add it via LD_LIBRARY_PATH on the service.
#
# capSysAdmin is deliberately OFF: Hyprland is wlroots-based, so Sunshine
# captures via wlr-screencopy and never needs CAP_SYS_ADMIN. Keeping the setcap
# wrapper would be worse than useless here — glibc runs setcap binaries in
# secure-execution mode, which *ignores* LD_LIBRARY_PATH, so it would break the
# libcuda loading from (2) and take NVENC down with it.
#
# The NVIDIA specifics above are the only vendor-aware bits; capSysAdmin =
# false + wlr-screencopy is correct for any wlroots compositor, and on an
# AMD/Intel host you'd drop cudaSupport and use VAAPI instead.
#
# First run: open https://<host>:47990 to set the web-UI credentials, then pair
# the Shield (enter the PIN Moonlight shows). Moonlight discovers the host via
# Sunshine's built-in mDNS.
{
  services.sunshine = {
    enable = true;
    package = pkgs.sunshine.override { cudaSupport = true; };
    autoStart = true; # start with the graphical session
    openFirewall = true; # 47984-48010 TCP + 47998-48010 UDP for Moonlight
    capSysAdmin = false; # wlr-screencopy capture; see header re: libcuda
  };

  # Let Sunshine find the NVIDIA driver's libcuda.so.1 for NVENC. Merges into
  # the module's own systemd.user.services.sunshine definition.
  systemd.user.services.sunshine.environment.LD_LIBRARY_PATH = "/run/opengl-driver/lib";

  # wlr-screencopy only exists under Hyprland. Plasma and gaming mode capture
  # over KMS, which needs CAP_SYS_ADMIN, via a separate wrapper so the Hyprland
  # path is unchanged. `capture=kms` overrides `capture = wlr` in sunshine.conf.
  security.wrappers.sunshine-kms = {
    owner = "root";
    group = "root";
    capabilities = "cap_sys_admin+p";
    source = lib.getExe config.services.sunshine.package;
  };

  systemd.user.services.sunshine.serviceConfig.ExecStart = lib.mkForce (
    lib.getExe (
      pkgs.writeShellApplication {
        name = "sunshine-session";
        runtimeInputs = [ pkgs.procps ];
        text = ''
          if pgrep -u "$(id -u)" -x Hyprland >/dev/null; then
            exec ${lib.getExe config.services.sunshine.package} "$@"
          fi
          exec ${config.security.wrapperDir}/sunshine-kms capture=kms "$@"
        '';
      }
    )
  );

  # hardware.uinput (pulled in by services.sunshine) makes /dev/uinput
  # root:uinput 0660 and adds nobody to the group, so sunshine's virtual mouse
  # and keyboard die with "Permission denied" and the stream takes no input.
  users.groups.uinput.members = [ "naps62" ];

  # DualSense/DualShock emulation. Sunshine presents a *real* PS5 HID (touchpad,
  # motion, LEDs, rumble) via /dev/uhid, not plain uinput — a uinput pad can't
  # carry those features. The kernel uhid node is root-only (0600) with no udev
  # rule, so Sunshine (a user service) can't open it and silently falls back to
  # an Xbox pad: "Unable to create virtual DualShock 5 controller: Permission
  # denied".
  #
  # NOTE: `uaccess` does NOT work for uhid — unlike uinput it isn't attached to
  # the seat (no `seat` tag), so logind never grants the ACL. Use a group grant
  # instead, mirroring Sunshine's upstream uinput rule: group `input`, mode 0660
  # (naps62 is already in `input`). Deterministic, no seat/session dependency.
  boot.kernelModules = [ "uhid" ];
  services.udev.extraRules = ''
    KERNEL=="uhid", SUBSYSTEM=="misc", MODE="0660", GROUP="input"
  '';
}
