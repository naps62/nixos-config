{ pkgs, ... }:
{
  home.packages = with pkgs; [
    typescript-language-server
    # nodejs_26, not the nixpkgs default 24: rev's package.json sets
    # engines >=26, and its systemd unit pins the same major.
    nodejs_26
    pnpm
  ];
}
