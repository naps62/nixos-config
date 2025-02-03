{ pkgs, ... }:
{
  home.packages = with pkgs; [
    rustup
    bacon
    mprocs
    pkg-config
    openssl.dev
    taplo
    sccache
  ];

  home.sessionPath = [ "\${CARGO_HOME:-~/.cargo}/bin" ];

  # systemd.user.services.ra-multiplex = {
  #   Service = {
  #     ExecStart = "${pkgs.ra-multiplex}/bin/ra-multiplex server";
  #   };
  #   Install.WantedBy = [ "default.target" ];
  # };

  home.sessionVariables = {
    OPENSSL_DIR = "${pkgs.openssl.dev}";
    OPENSSL_LIB_DIR = "${pkgs.openssl.out}/lib";
    OPENSSL_INCLUDE_DIR = "${pkgs.openssl.dev}/include";
  };
}
