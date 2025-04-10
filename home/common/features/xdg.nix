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
        "x-scheme-handler/http" = "zen-twilight.desktop";
        "x-scheme-handler/https" = "zen-twilight.desktop";
        "x-scheme-handler/avbout" = "zen-twilight.desktop";
        "x-scheme-handler/unknown" = "zen-twilight.desktop";

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
        "application/pdf" = "org.pwmt.zathura.desktop";
        "application/fdf" = "org.pwmt.zathura.desktop";
        "application/pdx" = "org.pwmt.zathura.desktop";
        "application/x-pdf" = "org.pwmt.zathura.desktop";
        "application/xfdf" = "org.pwmt.zathura.desktop";

        # files
        "inode/directory" = "thunar.desktop";
      };
    };
  };
}
