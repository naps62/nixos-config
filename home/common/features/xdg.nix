{ ... }:
{
  xdg = {
    userDirs = {
      enable = true;
      createDirectories = true;
      desktop = null;
      documents = null;
      download = "downloads";
      music = null;
      pictures = null;
      publicShare = null;
      templates = null;
      videos = null;
    };

    mimeApps = {
      enable = true;
      defaultApplications = {
        # web
        "text/html" = "google-chrome.desktop";
        "x-scheme-handler/http" = "google-chrome.desktop";
        "x-scheme-handler/https" = "google-chrome.desktop";
        "x-scheme-handler/avbout" = "google-chrome.desktop";
        "x-scheme-handler/unknown" = "google-chrome.desktop";

        # video
        "video/mp4" = "mpv.desktop";
        "video/webm" = "mpv.desktop";
        "video/x-flv" = "mpv.desktop";
        "video/x-matroska" = "mpv.desktop";
        "video/x-ms-wmv" = "mpv.desktop";

        # images
        "image/jpeg" = "imv.desktop";
        "image/png" = "imv.desktop";

        # pdfs
        "application/pdf" = "zathura.pdf";
        "application/fdf" = "zathura.pdf";
        "application/pdx" = "zathura.pdf";
        "application/x-pdf" = "zathura.pdf";
        "application/xfdf" = "zathura.pdf";

        # files
        "inode/directory" = "thunar.desktop";
      };
    };
  };
}
