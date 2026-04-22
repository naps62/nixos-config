{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    godot
    gdtoolkit_4
  ];
}
