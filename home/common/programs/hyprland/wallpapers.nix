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

  # Wallpaper fetch script - downloads wallpapers to cache
  fetchScript = pkgs.writeShellScript "wallpaper-fetch" ''
    set -euo pipefail

    HORIZONTAL_DIR="$HOME/.cache/wallpapers/3840x2160"
    VERTICAL_DIR="$HOME/.cache/wallpapers/2160x3840"
    mkdir -p "$HORIZONTAL_DIR" "$VERTICAL_DIR"

    HORIZONTAL=(${builtins.concatStringsSep " " (map (url: ''"${url}"'') horizontal)})
    VERTICAL=(${builtins.concatStringsSep " " (map (url: ''"${url}"'') vertical)})

    download() {
      local url="$1"
      local dir="$2"
      local filename=$(basename "$url")
      local filepath="$dir/$filename"

      if [ ! -f "$filepath" ]; then
        echo "Downloading $filename..." >&2
        ${pkgs.curl}/bin/curl -sSL -o "$filepath" "$url" || {
          echo "Failed to download $url" >&2
          return 1
        }
      fi
    }

    echo "Fetching horizontal wallpapers..."
    for url in "''${HORIZONTAL[@]}"; do
      download "$url" "$HORIZONTAL_DIR"
    done

    echo "Fetching vertical wallpapers..."
    for url in "''${VERTICAL[@]}"; do
      download "$url" "$VERTICAL_DIR"
    done

    echo "Done. Wallpapers cached in:"
    echo "  Horizontal: $HORIZONTAL_DIR"
    echo "  Vertical:   $VERTICAL_DIR"
  '';
in
{
  home.file.".local/bin/wallpaper-fetch".source = fetchScript;
}
