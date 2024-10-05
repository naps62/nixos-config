{ pkgs, ... }: {
  home.packages = with pkgs; [ rustup ];
  home.sessionPath = [ "\${CARGO_HOME:-~/.cargo}/bin" ];
}
