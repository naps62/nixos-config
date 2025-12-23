{
  lib,
  config,
  pkgs,
  ...
}:
let
  venvDir = "$HOME/.local/share/nerd-dictation/venv";

  # Create an FHS environment where vosk can be pip-installed
  nerd-dictation-env = pkgs.buildFHSEnv {
    name = "nerd-dictation-fhs";
    targetPkgs = pkgs: with pkgs; [
      # Python and pip for vosk
      python3
      python3Packages.pip
      python3Packages.virtualenv

      # Audio recording (pipewire)
      pipewire
      pulseaudio # for parec

      # Input simulation (wayland-compatible)
      ydotool
      wtype
      xdotool

      # Manylinux compatibility
      pythonManylinuxPackages.manylinux2014Package
    ];
    runScript = "bash";
  };

  # Fetch nerd-dictation from GitHub
  nerd-dictation-src = pkgs.fetchFromGitHub {
    owner = "ideasman42";
    repo = "nerd-dictation";
    rev = "main";
    hash = "sha256-xjaHrlJvk8bNvWp1VE4EAHi2VJlAutBxUgWB++3Qo+s=";
  };

  modelUrl = "https://alphacephei.com/vosk/models/vosk-model-en-us-0.22-lgraph.zip";
  modelName = "vosk-model-en-us-0.22-lgraph";
  modelDir = "$HOME/.config/nerd-dictation";

  # Wrapper script that handles setup and runs nerd-dictation
  nerd-dictation = pkgs.writeShellScriptBin "nerd-dictation" ''
    set -e
    VENV="${venvDir}"
    MODEL_DIR="${modelDir}"

    # Setup venv if needed
    if [ ! -d "$VENV" ]; then
      echo "[nerd-dictation] Setting up Python venv and installing vosk..."
      ${nerd-dictation-env}/bin/nerd-dictation-fhs -c "
        set -e
        mkdir -p \$(dirname ${venvDir})
        python3 -m venv ${venvDir}
        source ${venvDir}/bin/activate
        pip install --upgrade pip -q
        pip install vosk -q
      "
      echo "[nerd-dictation] Venv ready."
    fi

    # Download model if needed
    if [ ! -d "$MODEL_DIR/model" ]; then
      echo "[nerd-dictation] Downloading VOSK model (${modelName})..."
      mkdir -p "$MODEL_DIR"
      cd "$MODEL_DIR"
      ${pkgs.curl}/bin/curl -L --progress-bar -o "${modelName}.zip" "${modelUrl}"
      echo "[nerd-dictation] Extracting model..."
      ${pkgs.unzip}/bin/unzip -q "${modelName}.zip"
      mv "${modelName}" model
      rm "${modelName}.zip"
      echo "[nerd-dictation] Model ready."
    fi

    exec ${nerd-dictation-env}/bin/nerd-dictation-fhs -c "source $VENV/bin/activate && python3 ${nerd-dictation-src}/nerd-dictation $*"
  '';

  # Toggle script for hyprland keybind
  nerd-dictation-toggle = pkgs.writeShellScriptBin "nerd-dictation-toggle" ''
    hyprctl() {
      env -u LD_LIBRARY_PATH ${pkgs.hyprland}/bin/hyprctl "$@"
    }

    set_border() {
      local size=$1
      local color=$2
      # Unset existing rules for single-window workspaces
      hyprctl keyword windowrulev2 "unset, floating:0, onworkspace:w[t1]"
      hyprctl keyword windowrulev2 "unset, floating:0, onworkspace:w[tg1]"
      hyprctl keyword windowrulev2 "unset, floating:0, onworkspace:f[1]"
      hyprctl keyword windowrulev2 "unset, fullscreen:1"
      # Re-add with specified border size
      hyprctl keyword windowrulev2 "bordersize $size, floating:0, onworkspace:w[t1]"
      hyprctl keyword windowrulev2 "rounding 0, floating:0, onworkspace:w[t1]"
      hyprctl keyword windowrulev2 "bordersize $size, floating:0, onworkspace:w[tg1]"
      hyprctl keyword windowrulev2 "rounding 0, floating:0, onworkspace:w[tg1]"
      hyprctl keyword windowrulev2 "bordersize $size, floating:0, onworkspace:f[1]"
      hyprctl keyword windowrulev2 "rounding 0, floating:0, onworkspace:f[1]"
      hyprctl keyword windowrulev2 "bordersize $size, fullscreen:1"
      # Set border color
      hyprctl keyword general:col.active_border "$color"
    }

    # Check if currently suspended (file exists when suspended)
    if [ -f "$HOME/.cache/nerd-dictation-suspended" ]; then
      nerd-dictation resume
      rm -f "$HOME/.cache/nerd-dictation-suspended"
      set_border 5 "rgb(ff0000)"
    else
      nerd-dictation suspend
      touch "$HOME/.cache/nerd-dictation-suspended"
      set_border 0 "0x99999999"
    fi
  '';
in
{
  home.packages = [
    nerd-dictation
    nerd-dictation-toggle
    pkgs.ydotool
  ];

  # Note: You may need to enable ydotoold as a systemd service
  # Either via NixOS configuration or by running: ydotoold &
}
