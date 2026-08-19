{ pkgs, ... }:
{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        terminal = "${pkgs.kitty}/bin/kitty";
        layer = "overlay";
        font = "FiraCode Nerd Font:size=12";
        icon-theme = "Tela black";
        lines = 12;
        width = 40;
        inner-pad = 8;
      };
      border = {
        radius = 12;
        width = 1;
      };
      colors = {
        background = "2e3440f0";
        text = "eceff4ff";
        match = "88c0d0ff";
        selection = "434c5eff";
        selection-text = "eceff4ff";
        border = "4c566aff";
      };
    };
  };

  services.mako = {
    enable = true;
    settings = {
      font = "FiraCode Nerd Font 11";
      background-color = "#2e3440f0";
      text-color = "#eceff4";
      border-color = "#4c566a";
      border-radius = 12;
      border-size = 1;
      padding = "14";
      margin = "12";
      default-timeout = 6000;
      anchor = "top-right";
      layer = "overlay";
    };
  };

  # swayosd: the on-screen volume/brightness/caps-lock popup. Noctalia drew this
  # before; without it the XF86 keys still work but give no feedback, which reads
  # as "the keys are dead". swayosd-client does the change *and* the popup, so the
  # binds in default.nix call it instead of wpctl/brightnessctl directly.
  services.swayosd = {
    enable = true;
    topMargin = 0.85;
    stylePath = pkgs.writeText "swayosd-style.css" ''
      window#osd {
        padding: 12px 20px;
        border-radius: 12px;
        border: 1px solid #4c566a;
        background: alpha(#2e3440, 0.94);
      }

      window#osd #container { margin: 12px; }

      window#osd image,
      window#osd label { color: #eceff4; }

      window#osd progressbar:disabled { opacity: 0.5; }

      window#osd trough {
        min-height: 6px;
        border-radius: 6px;
        background: #434c5e;
      }

      window#osd progress {
        min-height: 6px;
        border-radius: 6px;
        background: #88c0d0;
      }
    '';
  };

  services.hyprpolkitagent.enable = true;
}
