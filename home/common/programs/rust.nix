{ pkgs, ... }:
{
  home.packages = with pkgs; [
    rustup
    bacon
    libgcc
  ];
  home.sessionPath = [ "\${CARGO_HOME:-~/.cargo}/bin" ];
}
