{ pkgs, ... }:
{
  home.packages = with pkgs; [
    rustup
    bacon
  ];
  home.sessionPath = [ "\${CARGO_HOME:-~/.cargo}/bin" ];
}
