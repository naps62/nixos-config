{
  config,
  lib,
  pkgs,
  ...
}:
# Moonlight — client counterpart to the Sunshine host
# (hosts/common/features/gaming/sunshine.nix). User-space, so it lives here in
# the home gaming module rather than next to the Sunshine service.
#
# Gated by its own option, independent of `custom.gaming.enable`: a laptop can
# install just the streaming client without the full launcher/Proton toolkit.
#
# First run: launch `moonlight`, then pair to the Sunshine host by entering the
# PIN Moonlight shows into Sunshine's web UI (https://<host>:47990). Moonlight
# discovers hosts on the LAN via Sunshine's mDNS.
let
  cfg = config.custom.gaming;
in
{
  options.custom.gaming.moonlight = lib.mkEnableOption "Moonlight game-streaming client";

  config = lib.mkIf cfg.moonlight {
    home.packages = [ pkgs.moonlight-qt ];
  };
}
