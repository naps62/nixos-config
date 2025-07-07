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

    initContent = ''
      # mise
      eval "$(mise activate zsh)"

      # asdf-vm
      . "$HOME/.nix-profile/share/asdf-vm/asdf.sh"

      [[ -f ~/.secrets.zsh ]] && source ~/.secrets.zsh

      export PATH="$HOME/.bin:$PATH"
      export FOUNDRY_DISABLE_NIGHTLY_WARNING=true
      # export PKG_CONFIG_PATH=$(nix eval --raw nixpkgs.openssl.dev)/lib/pkgconfig:$PKG_CONFIG_PATH
      # export LIBRARY_PATH=$(nix eval --raw nixpkgs.openssl.dev)/lib:$LIBRARY_PATH
      # export LD_LIBRARY_PATH=$(nix eval --raw nixpkgs.openssl.dev)/lib:$LD_LIBRARY_PATH
      export LD_LIBRARY_PATH=${pkgs.icu}/lib:${pkgs.stdenv.cc.cc.lib}/lib:$LD_LIBRARY_PATH
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

      # Disable language modules to keep prompt short
      nodejs.disabled = true;
      python.disabled = true;
      rust.disabled = true;
      golang.disabled = true;
      java.disabled = true;
      ruby.disabled = true;
      php.disabled = true;
      elixir.disabled = true;
      elm.disabled = true;
      haskell.disabled = true;
      julia.disabled = true;
      kotlin.disabled = true;
      lua.disabled = true;
      nim.disabled = true;
      nix_shell.disabled = true;
      ocaml.disabled = true;
      perl.disabled = true;
      purescript.disabled = true;
      scala.disabled = true;
      swift.disabled = true;
      terraform.disabled = true;
      zig.disabled = true;
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
    fd
  ];

  home.sessionPath = [
    "./.git/safe/../../node_modules/.bin"
    "./.git/safe/../../bin"
  ];
}
