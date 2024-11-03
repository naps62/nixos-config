{ pkgs, ... }:
{
  home.packages = with pkgs; [
    rustup
    bacon
    mprocs
  ];

  home.sessionPath = [ "\${CARGO_HOME:-~/.cargo}/bin" ];
}
