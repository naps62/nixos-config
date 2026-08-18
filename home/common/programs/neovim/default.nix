{ inputs, pkgs, ... }:
{
  imports = [ inputs.nvchad4nix.homeManagerModules.nvchad ];
  home.sessionVariables = {
    EDITOR = "nvim";
  };
  home.packages = with pkgs; [
    nixfmt
    biome
    stylua
  ];

  programs.nvchad = {
    enable = true;

    # Neovim only auto-picks OSC 52 when it finds no clipboard tool, but
    # wl-clipboard is on every host — so over SSH it writes the *remote*
    # clipboard instead. Locally wl-copy stays: kitty refuses OSC 52 reads.
    extraConfig = ''
      if vim.env.SSH_TTY and vim.env.SSH_TTY ~= "" then
        vim.g.clipboard = "osc52"
      end
    '';
  };
}
