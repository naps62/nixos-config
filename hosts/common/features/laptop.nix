{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ acpi ];

  powerManagement = {
    enable = true;
    powertop = true;
  };

  services = {
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

  environment.systemPackages = with pkgs; [
    brightnessctl
  ];
}
