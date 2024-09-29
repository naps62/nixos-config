{ inputs, ... }: {
  programs = {
    home-manager.enable = true;
    git.enable = true;
    fzf.enable = true;
    neovim.enable = true;
    ripgrep.enable = true;
    gh.enable = true;
    btop.enable = true;
    lazygit.enable = true;
  };
}
