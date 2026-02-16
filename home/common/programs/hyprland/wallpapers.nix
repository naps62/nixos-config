{ pkgs, ... }:
let
  # Horizontal wallpapers (3840x2160) for HDMI-A-1 and DP-1
  # Just add any image URL you want here
  horizontal = [
    "https://images.hdqwalls.com/download/black-red-square-rectangle-rq-3840x2160.jpg"
    "https://images.hdqwalls.com/download/metals-shapes-abstract-8k-8c-3840x2160.jpg"
    "https://images.hdqwalls.com/download/vertical-lines-colorful-abstract-5k-hu-3840x2160.jpg"
    "https://images.hdqwalls.com/download/cyberpunk-drive-neon-metropolis-if-3840x2160.jpg"
    "https://images.hdqwalls.com/download/horizon-zero-dawn-abstract-m2-3840x2160.jpg"
    "https://images.hdqwalls.com/download/pcb-circuit-board-abstract-x3-3840x2160.jpg"
    "https://images.hdqwalls.com/download/upcoming-stars-6h-3840x2160.jpg"
    "https://images.hdqwalls.com/download/abstract-colors-glitter-4k-8m-3840x2160.jpg"
    "https://images.hdqwalls.com/download/rainbow-spectrum-4k-h2-3840x2160.jpg"
    "https://images.hdqwalls.com/download/time-lapse-photography-tf-3840x2160.jpg"
    "https://images.hdqwalls.com/download/women-bokeh-rain-7q-3840x2160.jpg"
    "https://images.hdqwalls.com/download/fire-bokeh-5k-vm-3840x2160.jpg"
    "https://images.hdqwalls.com/download/train-track-ocean-beach-mountain-photography-5k-mh-3840x2160.jpg"
    "https://images.hdqwalls.com/download/bullet-train-motion-view-from-inside-ld-3840x2160.jpg"
    "https://images.hdqwalls.com/download/long-exposure-photo-of-a-highway-gf-3840x2160.jpg"
    "https://images.hdqwalls.com/download/hohenschwangau-castle-in-germany-5k-tb-3840x2160.jpg"
    "https://images.hdqwalls.com/download/girl-watching-glowing-metropolis-tg-3840x2160.jpg"
    "https://images.hdqwalls.com/download/cosmic-storm-over-alien-metropolis-dl-3840x2160.jpg"
    "https://images.hdqwalls.com/download/win-11-abstract-5k-7o-3840x2160.jpg"
    "https://images.hdqwalls.com/download/windows-11-5k-zz-3840x2160.jpg"
    "https://images.hdqwalls.com/download/localhost-lab-where-ideas-take-shape-ij-3840x2160.jpg"
    "https://images.hdqwalls.com/download/ipad-os18-purple-dark-jf-3840x2160.jpg"
    "https://images.hdqwalls.com/download/linux-nixos-7q-3840x2160.jpg"
    "https://images.hdqwalls.com/download/macbook-pro-m2-js-3840x2160.jpg"
    "https://images.hdqwalls.com/download/0101-dw-3840x2160.jpg"
    "https://images.hdqwalls.com/download/apple-studio-display-wwdc-qg-3840x2160.jpg"
    "https://images.hdqwalls.com/download/starfield-i-mac-ie-3840x2160.jpg"
  ];

  # Vertical wallpapers (2160x3840) for DP-2
  # Same images in vertical resolution
  vertical = [
    "https://images.hdqwalls.com/download/black-red-square-rectangle-rq-2160x3840.jpg"
    "https://images.hdqwalls.com/download/metals-shapes-abstract-8k-8c-2160x3840.jpg"
    "https://images.hdqwalls.com/download/vertical-lines-colorful-abstract-5k-hu-2160x3840.jpg"
    "https://images.hdqwalls.com/download/cyberpunk-drive-neon-metropolis-if-2160x3840.jpg"
    "https://images.hdqwalls.com/download/horizon-zero-dawn-abstract-m2-2160x3840.jpg"
    "https://images.hdqwalls.com/download/pcb-circuit-board-abstract-x3-2160x3840.jpg"
    "https://images.hdqwalls.com/download/upcoming-stars-6h-2160x3840.jpg"
    "https://images.hdqwalls.com/download/abstract-colors-glitter-4k-8m-2160x3840.jpg"
    "https://images.hdqwalls.com/download/rainbow-spectrum-4k-h2-2160x3840.jpg"
    "https://images.hdqwalls.com/download/time-lapse-photography-tf-2160x3840.jpg"
    "https://images.hdqwalls.com/download/women-bokeh-rain-7q-2160x3840.jpg"
    "https://images.hdqwalls.com/download/fire-bokeh-5k-vm-2160x3840.jpg"
    "https://images.hdqwalls.com/download/train-track-ocean-beach-mountain-photography-5k-mh-2160x3840.jpg"
    "https://images.hdqwalls.com/download/bullet-train-motion-view-from-inside-ld-2160x3840.jpg"
    "https://images.hdqwalls.com/download/long-exposure-photo-of-a-highway-gf-2160x3840.jpg"
    "https://images.hdqwalls.com/download/hohenschwangau-castle-in-germany-5k-tb-2160x3840.jpg"
    "https://images.hdqwalls.com/download/girl-watching-glowing-metropolis-tg-2160x3840.jpg"
    "https://images.hdqwalls.com/download/cosmic-storm-over-alien-metropolis-dl-2160x3840.jpg"
    "https://images.hdqwalls.com/download/win-11-abstract-5k-7o-2160x3840.jpg"
    "https://images.hdqwalls.com/download/windows-11-5k-zz-2160x3840.jpg"
    "https://images.hdqwalls.com/download/localhost-lab-where-ideas-take-shape-ij-2160x3840.jpg"
    "https://images.hdqwalls.com/download/ipad-os18-purple-dark-jf-2160x3840.jpg"
    "https://images.hdqwalls.com/download/linux-nixos-7q-2160x3840.jpg"
    "https://images.hdqwalls.com/download/macbook-pro-m2-js-2160x3840.jpg"
    "https://images.hdqwalls.com/download/0101-dw-2160x3840.jpg"
    "https://images.hdqwalls.com/download/apple-studio-display-wwdc-qg-2160x3840.jpg"
    "https://images.hdqwalls.com/download/starfield-i-mac-ie-2160x3840.jpg"
  ];

  # Create wallpaper rotation script
  rotateScript = pkgs.writeShellScript "hyprpaper-rotate" ''
    set -euo pipefail

    # Check if hyprpaper is running
    if ! pgrep -x hyprpaper > /dev/null; then
      echo "Error: hyprpaper is not running"
      echo "Start it with: hyprpaper &"
      exit 1
    fi

    CACHE_DIR="$HOME/.cache/wallpapers"
    mkdir -p "$CACHE_DIR"

    # Arrays of wallpaper URLs
    HORIZONTAL=(${builtins.concatStringsSep " " (map (url: ''"${url}"'') horizontal)})
    VERTICAL=(${builtins.concatStringsSep " " (map (url: ''"${url}"'') vertical)})

    # Function to download wallpaper if not cached
    get_wallpaper() {
      local url="$1"
      local filename=$(basename "$url")
      local filepath="$CACHE_DIR/$filename"

      if [ ! -f "$filepath" ]; then
        echo "Downloading $filename..." >&2
        ${pkgs.curl}/bin/curl -sSL -o "$filepath" "$url" || {
          echo "Failed to download $url" >&2
          return 1
        }
      fi

      echo "$filepath"
    }

    # Function to get random element from array
    random_choice() {
      local arr=("$@")
      local size=''${#arr[@]}
      local idx=$((RANDOM % size))
      echo "''${arr[$idx]}"
    }

    # Get list of connected monitors and their orientations
    readarray -t MONITORS < <(${pkgs.hyprland}/bin/hyprctl monitors -j | \
      ${pkgs.jq}/bin/jq -r '.[] | "\(.name)|\(.width)|\(.height)|\(.transform)"')

    # Apply wallpapers to each monitor
    for monitor_info in "''${MONITORS[@]}"; do
      IFS='|' read -r name width height transform <<< "$monitor_info"

      # Determine if monitor is vertical (considering transform)
      # transform 1 or 3 means 90/270 degree rotation
      if [[ "$transform" == "1" || "$transform" == "3" ]]; then
        # Transform swaps width/height, so check original dimensions
        if [ "$width" -lt "$height" ]; then
          # After transform, it's horizontal
          wallpaper_url=$(random_choice "''${HORIZONTAL[@]}")
        else
          # After transform, it's vertical
          wallpaper_url=$(random_choice "''${VERTICAL[@]}")
        fi
      else
        # No rotation or 180 degree rotation
        if [ "$width" -lt "$height" ]; then
          wallpaper_url=$(random_choice "''${VERTICAL[@]}")
        else
          wallpaper_url=$(random_choice "''${HORIZONTAL[@]}")
        fi
      fi

      # Download and apply wallpaper
      wallpaper_path=$(get_wallpaper "$wallpaper_url")
      if [ -n "$wallpaper_path" ]; then
        echo "Setting $name to $wallpaper_path" >&2
        ${pkgs.hyprland}/bin/hyprctl hyprpaper wallpaper "$name,$wallpaper_path,cover"
      fi
    done
  '';
in
{
  # Export for use in monitors.nix
  home.file.".local/bin/hyprpaper-rotate".source = rotateScript;

  # Systemd service and timer for rotation
  systemd.user.services.hyprpaper-rotate = {
    Unit = {
      Description = "Rotate Hyprland wallpapers";
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${rotateScript}";
    };
  };

  systemd.user.timers.hyprpaper-rotate = {
    Unit = {
      Description = "Rotate Hyprland wallpapers every 12 hours";
    };
    Timer = {
      OnUnitActiveSec = "12h";
      Persistent = true;
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}
