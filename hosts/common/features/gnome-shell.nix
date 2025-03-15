{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    gnome-shell
  ];

  environment.variables = {
    GDK_SCALE = "2";
    GDK_DPI_SCALE = "1.5";
  };
}
