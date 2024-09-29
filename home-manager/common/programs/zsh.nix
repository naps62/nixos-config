{ inputs, ... }: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      c = "cargo";
      d = "docker";
      dc = "docker compose";
      g = "git";
      n = "nvim";
      vim = "nvim";
      mm = "mise";
      mr = "mise run";
      ls = "eza";
      cat = "bat";
      ps = "procs";
    };

    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };
  };

  programs.starship = {
    enable = true;
    settings = { add_newline = true; };
  };
}
