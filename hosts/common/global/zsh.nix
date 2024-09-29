{ inputs, ... }: {
  programs.zsh.enable = true;
  programs.starship = {
    enable = true;
    settings = { add_newline = true; };
  };
}
