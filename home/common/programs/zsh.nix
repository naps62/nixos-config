{
  inputs,
  config,
  pkgs,
  ...
}:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    completionInit = "autoload -U compinit && compinit -u";

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
      open = "xdg-open";
      o = "xdg-open";
      v = "nohup neovide &; disown";

      # cd
      ".." = "cd ..";
      "..2" = "cd ../..";
      "..3" = "cd ../../..";
    };

    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };

    plugins = [
      {
        name = "fzf-tab";
        src = pkgs.fetchFromGitHub {
          owner = "Aloxaf";
          repo = "fzf-tab";
          rev = "v1.1.2";
          hash = "sha256-Qv8zAiMtrr67CbLRrFjGaPzFZcOiMVEFLg1Z+N6VMhg=";
        };
      }
      {
        name = "zsh-autopair";
        src = pkgs.fetchFromGitHub {
          owner = "hlissner";
          repo = "zsh-autopair";
          rev = "449a7c3";
          hash = "sha256-3zvOgIi+q7+sTXrT+r/4v98qjeiEL4Wh64rxBYnwJvQ=";
        };
      }
    ];

    initExtra = ''
      # mise
      eval "$(mise activate zsh)"

      # asdf-vm
      . "$HOME/.nix-profile/share/asdf-vm/asdf.sh"

      [[ -f ~/.secrets.zsh ]] && source ~/.secrets.zsh
    '';
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
    };
  };

  home.packages = with pkgs; [
    btop
    inxi
    mise
    ripgrep
    pass
    bat
    procs
    eza
    asdf-vm
  ];

  home.sessionPath = [
    "./.git/safe/../../node_modules/.bin"
    "./.git/safe/../../bin"
  ];
}
