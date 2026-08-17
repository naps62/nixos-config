{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;

    # The @plugin lines and the tpm bootstrap are stripped from tmux.conf:
    # home-manager writes the run-shell lines for these itself, and tpm would
    # otherwise try to git-clone them into ~/.tmux/plugins at runtime.
    plugins = with pkgs.tmuxPlugins; [
      sensible
      resurrect
      continuum
    ];

    extraConfig = builtins.readFile ./tmux.conf;
  };
}
