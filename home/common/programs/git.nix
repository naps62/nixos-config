{ pkgs, ... }: {
  programs.git = {
    enable = true;
    userName = "Miguel Palhas";
    userEmail = "mpalhas@gmail.com";
    aliases = {
      ls =
        "log --color --graph --oneline --decorate --topo-order --pretty=format:'%C(yellow)%d%Creset %Cgreen(%cr)%Creset %C(bold blue)[%an]%Creset %s %Cred(%h)%Creset' --abbrev-commit";
      ll = ''
        log --reverse --pretty=format:"%C(yellow)%h%Cred%d\ %Creset%s%Cblue\ [%an]" --decorate --numstat'';
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
    };
    extraConfig = {
      core = {
        editor = "nvim";
        pager = "delta";
      };
    };
  };

  programs.delta.enable = true;
  programs.gh.enable = true;
}
