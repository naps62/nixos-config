{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:
{
  programs.gpg = {
    enable = true;
  };

  home.packages = with pkgs; [ pinentry-gnome3 ];

  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-gnome3;
  };

  programs.password-store = {
    enable = true;
    settings = {
      PASSWORD_STORE_DIR = "/home/naps62/sync/pass";
    };
  };
}
