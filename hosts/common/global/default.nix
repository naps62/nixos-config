{ inputs, pkgs, ... }: {
  imports =
    [ inputs.home-manager.nixosModules.home-manager ./nix.nix ./zsh.nix ];

  environment.systemPackages = [
    pkgs.btop
    pkgs.fzf
    pkgs.home-manager
    pkgs.ripgrep
    pkgs.zsh
    pkgs.git
    pkgs.neovim
  ];

  time = { timeZone = "Europe/Lisbon"; };

  networking = { networkmanager = { enable = true; }; };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "pt_PT.UTF-8";
      LC_IDENTIFICATION = "pt_PT.UTF-8";
      LC_MEASUREMENT = "pt_PT.UTF-8";
      LC_MONETARY = "pt_PT.UTF-8";
      LC_NAME = "pt_PT.UTF-8";
      LC_NUMERIC = "pt_PT.UTF-8";
      LC_PAPER = "pt_PT.UTF-8";
      LC_TELEPHONE = "pt_PT.UTF-8";
      LC_TIME = "pt_PT.UTF-8";
    };
  };
}
