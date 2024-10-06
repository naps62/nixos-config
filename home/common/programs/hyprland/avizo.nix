{ pkgs, ... }:
{
  services.avizo = {
    enable = true;
    settings = {
      time = 2.0;
    };
  };
}
