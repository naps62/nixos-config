{ inputs, pkgs, ... }: {
  environment.systemPackages = [
    pkgs.btop
    pkgs.fzf
    pkgs.home-manager
    pkgs.ripgrep
    pkgs.zsh
    pkgs.git
    pkgs.neovim
    pkgs.lazygit
    pkgs.mise
    pkgs.gh
    pkgs.pass
  ];

}
