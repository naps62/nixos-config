{
  inputs,
  pkgs,
  fonts,
  ...
}:
{
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      ubuntu_font_family
      libertine
      nerd-fonts.fira-code
      nerd-fonts.victor-mono
      roboto
    ];

    fontconfig = {
      defaultFonts = {
        serif = [ "Libertine" ];
        sansSerif = [ "Ubuntu" ];
        monospace = [ "FiraCode" ];
      };
    };
  };

}
