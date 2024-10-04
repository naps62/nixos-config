{ inputs, config, pkgs, ... }: {
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

      # cd
      ".." = "cd ..";
      "..2" = "cd ../..";
      "..3" = "cd ../../..";
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
      # mise
      eval "$(mise activate zsh)"

      # asdf
      ${pkgs.asdf-vm}/share/asdf-vm/asdf.sh
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

  home.sessionPath =
    [ "./.git/safe/../../node_modules/.bin" "./.git/safe/../../bin" ];
}
