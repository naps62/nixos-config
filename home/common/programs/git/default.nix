{ pkgs, ... }:
{
  xdg.configFile."git/commit-message.txt".source = ./commit-message.txt;
  xdg.configFile."git/ignore".source = ./ignore;

  programs.git = {
    enable = true;
    userName = "Miguel Palhas";
    userEmail = "mpalhas@gmail.com";
    aliases = {
      ls = "log --color --graph --oneline --decorate --topo-order --pretty=format:'%C(yellow)%d%Creset %Cgreen(%cr)%Creset %C(bold blue)[%an]%Creset %s %Cred(%h)%Creset' --abbrev-commit";
      ll = ''log --reverse --pretty=format:"%C(yellow)%h%Cred%d\ %Creset%s%Cblue\ [%an]" --decorate --numstat'';
      conf = "diff --name-only --diff-filter=U";
      ba = "branch -a";
      pb = "publish";
      ps = "push -u";
      pr = "pull-request";
      ppr = "push-pr";
      cpr = "close-pr";
      opr = "open-pr";
      f = "fetch";
      c = "commit --verbose";
      d = "diff";
      dc = "diff --cached";
      co = "checkout";
      s = "status -sb";
      b = "better-branch";
      rb = "rebase";
      rbc = "rebase --continue";
      w = "commit -am 'wip'";
    };
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
      core = {
        editor = "nvim";
        pager = "delta";
      };
      commit = {
        template = "~/.config/git/commit-message.txt";
      };
      push = {
        default = "upstream";
      };
      delta = {
        navigate = true;
      };
      "diff \"image\"" = {
        textconv = "mediainfo";
      };
      "diff \"text\"" = {
        textconv = "fold -s -w80";
      };
    };
  };

  home.packages = with pkgs; [
    delta
    mediainfo
  ];
  home.sessionPath = [
    "$HOME/.config/git/scripts"
  ];
  xdg.configFile = {
    "git/scripts".source = ./scripts;
  };
  programs.gh = {
    enable = true;

    settings = {
      aliases = {
        co = "pr checkout";
        ls = "pr list";
        pv = "pr view";
      };
    };
  };
}
