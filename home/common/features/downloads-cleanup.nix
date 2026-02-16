{ pkgs, config, lib, ... }:

let
  downloadsDir = "${config.home.homeDirectory}/downloads";
  # Age in days after which files should be deleted
  maxAge = 30;
in
{
  systemd.user.services.downloads-cleanup = {
    Unit = {
      Description = "Clean old files from downloads subdirectories";
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeShellScript "downloads-cleanup" ''
        set -euo pipefail

        echo "Starting downloads cleanup..."
        echo "Cleaning files older than ${toString maxAge} days from ${downloadsDir}/*/ (including hidden files)"

        # Find and delete files older than maxAge days in subdirectories of downloads
        # -mindepth 2 ensures we only look inside subdirectories, not in downloads/ itself
        # -type f ensures we only delete files, not directories
        # This includes hidden files and directories
        if [ -d "${downloadsDir}" ]; then
          ${pkgs.findutils}/bin/find "${downloadsDir}" \
            -mindepth 2 \
            -type f \
            -mtime +${toString maxAge} \
            -print \
            -delete 2>/dev/null || true

          # Also remove empty directories (including hidden ones)
          ${pkgs.findutils}/bin/find "${downloadsDir}" \
            -mindepth 2 \
            -type d \
            -empty \
            -print \
            -delete 2>/dev/null || true

          echo "Cleanup completed successfully"
        else
          echo "Downloads directory does not exist, skipping cleanup"
        fi
      ''}";
    };
  };

  systemd.user.timers.downloads-cleanup = {
    Unit = {
      Description = "Timer for downloads cleanup";
    };

    Timer = {
      OnCalendar = "daily";
      Persistent = true;
    };

    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}
