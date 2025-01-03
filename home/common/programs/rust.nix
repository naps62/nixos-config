{ pkgs, ... }:
{
  home.packages = with pkgs; [
    rustup
    bacon
    mprocs
    ra-multiplex
  ];

  home.sessionPath = [ "\${CARGO_HOME:-~/.cargo}/bin" ];

  systemd.user.services.ra-multiplex = {
    Service = {
      ExecStart = "${pkgs.ra-multiplex}/bin/ra-multiplex server";
    };
    Install.WantedBy = [ "default.target" ];
  };
}
