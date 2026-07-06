{ inputs, pkgs, ... }:
{
  # `default` is Zen's stable channel (branded "zen-beta", binary/desktop `zen-beta`).
  # Avoids twilight's recurring hash-mismatch breakage (nightly re-tags under the same version).
  home.packages = [ inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default ];
}
