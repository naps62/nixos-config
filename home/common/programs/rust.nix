{ pkgs, ... }:
{
  home.packages = with pkgs; [
    rustup
    bacon
    openssl
    openssl_3
    pkg-config
    glib
    glib.dev
    gtk3
    libsoup
    webkitgtk
    dbus
    librsvg
  ];

  home.sessionPath = [ "\${CARGO_HOME:-~/.cargo}/bin" ];
}
