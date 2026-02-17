{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    brightnessctl
  ];

  powerManagement = {
    enable = true;
    powertop.enable = true;
  };

  services = {
    upower.enable = true;
    thermald.enable = true;
    power-profiles-daemon.enable = false;

    auto-cpufreq = {
      enable = true;
      settings = {
        battery = {
          governor = "powersave";
          turbo = "never";
        };
        charger = {
          governor = "performance";
          turbo = "auto";
        };
      };
    };
  };
}
