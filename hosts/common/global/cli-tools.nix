{ inputs, pkgs, ... }: {
  environment.systemPackages = [
    pkgs.btop
    pkgs.fzf
    pkgs.home-manager
    pkgs.ripgrep
    pkgs.git
    pkgs.lazygit
    pkgs.mise
    pkgs.gh
    pkgs.pass
    pkgs.bat
    pkgs.procs
    pkgs.eza
  ];

}
