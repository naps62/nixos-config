{ inputs, config, ... }: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
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

    zplug = {
      enable = true;
      plugins =
        [ { name = "hlissner/zsh-autopair"; } { name = "Aloxaf/fzf-tab"; } ];
    };

    initExtra = ''
      eval "$(mise activate zsh)"
    '';
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.starship = {
    enable = true;
    settings = { add_newline = true; };
  };
}
