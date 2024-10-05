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
      fira-code
      fira-code-symbols
      (nerdfonts.override {
        fonts = [
          "FiraCode"
          "VictorMono"
        ];
      })
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
