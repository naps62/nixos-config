{
  lib,
  config,
  pkgs,
  ...
}:
{
  programs = {
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
  };

  home.packages = with pkgs; [
    imagemagick
    doctl
    aider-chat
    inotify-tools
    devenv
    # bruno
    zed-editor
  ];

  programs.tmux = {
    enable = true;
    extraConfig = ''
      setw -g mouse on
      set -s extended-keys on
    '';
  };

  home.file.".claude/settings.json".text = ''
     {
       "permissions": {
          "allow": [
          "Bash(mkdir:*)",
          "Bash(rg:*)",
          "Bash(chmod:*)",
          "Bash(find:*)",
          "Bash(rustup target:*)",
          "Bash(ls:*)",
          "Bash(cargo:*)",
          "Bash(cp:*)",
          "Bash(yarn:*)",
          "Bash(sed:*)",
          "Bash(gh:*)",
          "Bash(git:*)",
          "Bash(grep:*)",
          "Bash(node:*)"
        ],
        "defaultMode": "acceptEdits"
      }
    }
  '';
}
