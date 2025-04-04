{
  lib,
  config,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    aider-chat
  ];

  home.file.".aider.conf.yml".text = ''
    code-theme: one-dark
    auto-commits: false
  '';
}
