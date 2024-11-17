{ pkgs, ... }:
{
  home.packages = with pkgs; [
    rustup
    bacon
    mprocs
  ];

  home.sessionPath = [ "\${CARGO_HOME:-~/.cargo}/bin" ];

  systemd.user.services.ra-multiplex = {
    Service = {
      ExecStart = "/home/naps62/.cargo/bin/ra-multiplex server";
    };
    Install.WantedBy = [ "multi-user.target" ];
  };
}
