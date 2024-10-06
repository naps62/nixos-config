{ pkgs, inputs, ... }:
{

  home.sessionVariables = {
    BROWSER = "firefox";
  };

  programs.firefox = {
    enable = true;
    policies = {
      DefaultDownloadDirectory = "$HOME/downloads/firefox";
      DontCheckDefaultBrowser = true;
      DisableTelemetry = true;
      DisablePocket = true;
      DisableFirefoxStudies = true;

      DisplayBookmarksToolbar = "never";
      DisplayMenuBar = "never";

      OverrideFirstRunPage = "";
      PromptForDownloadLocation = false;

      HardwareAcceleration = true;
      TranslateEnabled = true;

      Homepage.StartPage = "previous-session";

      UserMessaging = {
        SkipOnboarding = true;
      };

      FirefoxSuggest = {
        WebSuggestions = false;
        SponsoredSuggestions = false;
        ImproveSuggest = false;
      };

      EnableTrackingProtection = {
        Value = true;
        Cryptomining = true;
        Fingerprinting = true;
      };

      FirefoxHome = {
        Search = true;
        TopSites = true;
        SponsoredTopSites = true;
        Highlights = true;
        Pocket = false;
        SponsoredPocket = false;
        Snippets = false;
      };
    };

    profiles = {
      personal = {
        isDefault = true;
        extensions = with inputs.firefox-addons.packages.${pkgs.system}; [
          # privacy
          clearurls
          decentraleyes

          # content/ad blocking
          ublock-origin

          # quality of life
          no-pdf-download
          buster-captcha-solver

          # dev
          react-devtools
          translate-web-pages

          # manual use
          # tridactyl
          bitwarden
        ];
        settings = {
          # Performance settings
          "gfx.webrender.all" = true; # Force enable GPU acceleration
          "media.ffmpeg.vaapi.enabled" = true;
          "widget.dmabuf.force-enabled" = true; # Required in recent Firefoxes

          "widget.use-xdg-desktop-portal.file-picker" = true;

          # Hide the "sharing indicator", it's especially annoying
          # with tiling WMs on wayland
          "privacy.webrtc.legacyGlobalIndicator" = false;

          # Actual settings
          "browser.aboutConfig.showWarning" = false;
          "browser.newtabpage.pinned" = false;
          "browser.protections_panel.infoMessage.seen" = true;
          "browser.quitShortcut.disabled" = true;
          "browser.urlbar.suggest.openpage" = false;
          "privacy.trackingprotection.enabled" = true;
          "privacy.trackingprotection.socialtracking.enabled" = true;

          "mousewhell.system_scroll_override" = true;

          "extension.autoDisableScopes" = "0";
        };
      };
    };
  };
}
