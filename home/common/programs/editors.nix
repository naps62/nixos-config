{ pkgs, ... }:
{
  # Trialling GUI editors alongside neovim, for reviewing agent-generated
  # diffs. Drop the ones that don't stick.
  home.packages = with pkgs; [
    zed-editor
    code-cursor
    # VSCodium and Cursor both default to Open VSX, which carries
    # GitHub.vscode-pull-request-github. Zed has no PR review at all.
    vscodium
  ];
}
