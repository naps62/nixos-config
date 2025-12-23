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
    mold
    clang
  ];

  home.sessionPath = [ "\${CARGO_HOME:-~/.cargo}/bin" ];

  home.file.".cargo/config.toml".text = ''
    [target.x86_64-unknown-linux-gnu]
    linker = "clang"
    rustflags = ["-C", "link-arg=-fuse-ld=mold"]

    [build]
    rustflags = ["-Z", "threads=12"]

    # [unstable]
    # codegen-backend = true
    #
    # [profile.dev]
    # codegen-backend = "cranelift"
  '';

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
