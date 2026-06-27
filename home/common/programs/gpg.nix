{
  pkgs,
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
    # Use gpg-agent as the ssh-agent so AddKeysToAgent ("yes") in ssh.nix
    # has an agent to load keys into.
    enableSshSupport = true;
  };

  programs.password-store = {
    enable = true;
    settings = { };
  };
}
