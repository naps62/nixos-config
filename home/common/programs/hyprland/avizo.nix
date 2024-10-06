{ pkgs, ... }:
{
  services.avizo = {
    enable = true;
    settings = {
      default = {
        time = 1.0;
      };
    };
  };
}
