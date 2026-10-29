{ pkgs, lib, ... }:
let
  # The Steam client's "Switch to Desktop" runs `steamos-session-select`, which
  # neither Jovian's FHS env nor SteamOS-less NixOS provides (Jovian only ships
  # the older holo-session-select). Without it Steam sits on "Switching
  # desktop..." forever. Mode switching is steamosctl's job.
  steamosSessionSelect = pkgs.writeShellScriptBin "steamos-session-select" ''
    case "''${1:-gamescope}" in
      gamescope) exec steamosctl switch-to-game-mode ;;
      *) exec steamosctl switch-to-desktop-mode ;;
    esac
  '';

  # Steam runs inside an FHS sandbox with its own /usr, so the host symlink
  # /usr/bin/heroic (below) doesn't exist there: the shortcut Heroic's "Add to
  # Steam" creates exits 0 in under a second with no output. Hand the launch to
  # the user manager instead, so Heroic and Proton run on the host, outside the
  # sandbox, and Steam still tracks the game until it exits.
  heroicShim = pkgs.writeShellScriptBin "heroic" ''
    exec ${pkgs.systemd}/bin/systemd-run --user --quiet --collect --wait --pipe \
      --setenv=DISPLAY --setenv=WAYLAND_DISPLAY --setenv=XDG_SESSION_TYPE \
      /home/naps62/.nix-profile/bin/heroic "$@"
  '';
in
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
    # Jovian sets programs.steam.package without mkDefault.
    package = lib.mkForce (pkgs.steam.override {
      extraArgs = "-cef-disable-gpu-sandbox";
      extraPkgs = _: [
        steamosSessionSelect
        heroicShim
      ];
    });
  };

  hardware.steam-hardware.enable = true;

  # Heroic's "Add to Steam" hardcodes /usr/bin/heroic as the shortcut target,
  # which doesn't exist on NixOS. Heroic itself comes from home-manager.
  systemd.tmpfiles.rules = [
    "L+ /usr/bin/heroic - - - - /home/naps62/.nix-profile/bin/heroic"
  ];
}
