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
    agent = {
      enable = true;
      enableScDaemon = true;
    };
    pinentry = {
      enable = true;
      pinentryFlavor = "gnome3";
    };
    settings = {
      keyserver = "hkps://keys.openpgp.org";
      use-agent = true;
      use-agent-extra = true;
      no-greeting = true;
      verbose = true;
    };
  };

  programs.password-store.enable = true;
}
