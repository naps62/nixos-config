{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
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

    sessionPath = [ "\${CARGO_HOME:-$HOME/.cargo}/bin" ];

    file.".cargo/config.toml".text = ''
      [target.x86_64-unknown-linux-gnu]
      linker = "clang"
      rustflags = ["-C", "link-arg=-fuse-ld=mold"]

      [build]
      rustflags = ["-Z", "threads=12"]
    '';

    sessionVariables = {
      OPENSSL_DIR = "${pkgs.openssl.dev}";
      OPENSSL_LIB_DIR = "${pkgs.openssl.out}/lib";
      OPENSSL_INCLUDE_DIR = "${pkgs.openssl.dev}/include";
    };
  };
}
