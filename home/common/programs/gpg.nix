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
    pinentryPackage = pkgs.pinentry-gnome3;
  };
  # pinentry = {
  #   enable = true;
  #   pinentryFlavor = "gnome3";
  # };
  # settings = {
  #   keyserver = "hkps://keys.openpgp.org";
  #   use-agent = true;
  #   use-agent-extra = true;
  #   no-greeting = true;
  #   verbose = true;
  # };
  # };

  programs.password-store = {
    enable = true;
    settings = {
      PASSWORD_STORE_DIR = "~/sync/pass";
    };
  };
}
