{ pkgs, ... }:
{

  home.sessionVariables = {
    BROWSER = "zen-twilight";
  };

  programs.firefox = {
    enable = true;
    package = pkgs.firefox-devedition;
    policies = {
      DefaultDownloadDirectory = "$HOME/downloads";
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
  };
}
