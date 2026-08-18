{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.custom.hyprland;

  hyprPkgs = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system};

  # xdph runs this instead of hyprland-share-picker (screencopy:custom_picker_binary).
  # The contract is just "print [SELECTION] to stdout"; a leading "r" grants a
  # restore token. Printing it immediately means the dialog never renders.
  #
  # Why bypass the picker at all: Slack opens a burst of screencast sessions per
  # share and only asks for persist_mode=1, so the leading sessions race ahead of
  # their restore token and re-prompt. allow_token_by_default alone still left
  # ~3 dialogs per share.
  #
  # Escape hatch: `touch ~/.config/hypr/share-picker-manual` to get the real
  # picker back when you need a window or region instead of a whole screen.
  #
  # Deliberately NOT the focused monitor: at the moment you hit "share screen"
  # the focus is on the Slack/Chrome window, which is generally not the screen
  # you actually want to show. Auto-picking it would silently share the wrong
  # display. shareOutput is pinned per-host instead.
  sharePicker = pkgs.writeShellScriptBin "xdph-auto-picker" ''
    realPicker="${hyprPkgs.xdg-desktop-portal-hyprland}/bin/hyprland-share-picker"

    if [ -e "$HOME/.config/hypr/share-picker-manual" ]; then
      exec "$realPicker" "$@"
    fi

    want=${lib.escapeShellArg (toString cfg.shareOutput)}

    # Only auto-select if that output is actually connected right now; otherwise
    # fall back to the picker rather than sharing something unexpected.
    if ${hyprPkgs.hyprland}/bin/hyprctl monitors -j 2>/dev/null \
      | ${pkgs.jq}/bin/jq -e --arg o "$want" 'any(.[]; .name == $o)' >/dev/null 2>&1; then
      printf '[SELECTION]r/screen:%s\n' "$want"
    else
      exec "$realPicker" "$@"
    fi
  '';

  # Floating webcam preview for the "corner-cam" recording trick: run `webcam`,
  # then capture the whole screen with kooha/wf-recorder — the preview is in the
  # recording. v4l2 only (won't work with the laptop's IPU6 cam). Optional device
  # arg, e.g. `webcam /dev/video2`.
  webcam = pkgs.writeShellScriptBin "webcam" ''
    dev="''${1:-/dev/video0}"
    exec ${pkgs.mpv}/bin/mpv \
      --profile=low-latency --untimed \
      --no-osc --no-input-default-bindings \
      --title=webcam-overlay --border=no --ontop \
      "av://v4l2:$dev"
  '';
in
{
  options.custom.hyprland = {
    yaziSize = lib.mkOption {
      type = lib.types.str;
      default = "1400 1400";
      description = "Size of the yazi special workspace window";
    };
    cursorSize = lib.mkOption {
      type = lib.types.int;
      default = 24;
      description = "Cursor size for XCURSOR_SIZE and HYPRCURSOR_SIZE";
    };
    shareOutput = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "HDMI-A-1";
      description = ''
        Output that screen-sharing auto-selects, bypassing the xdph picker
        entirely. null keeps the normal picker. Falls back to the picker if
        the named output isn't currently connected.
      '';
    };
  };

  imports = [
    ./cursor.nix
    ./kbptr.nix
    ./noctalia
    ./wallpapers.nix
  ];

  config = {
    home.packages = with pkgs; [
      hyprcursor
      pamixer
      hyprshot
      satty
      playerctl
      hyprsunset
      libnotify
      cliphist
      wf-recorder
      slurp
      webcam
    ];

    home.sessionVariables = {
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
      # WebKitGTK (Tauri apps) renders blank/crashes on the DMABUF path across
      # many GPU/driver combos; disable it on all hosts.
      WEBKIT_DISABLE_DMABUF_RENDERER = "1";
    };

    # xdph's share-picker is stateless: the "Allow a restore token" checkbox
    # starts unticked, so no app ever receives a token and every single share
    # re-prompts (journal showed 0 "Sent restore token" in 30 days, always
    # re-selecting the same output). This pre-ticks it, so OBS/Chrome/Slack get
    # a token on first share and skip the dialog thereafter.
    # Note: xdph.conf is still hyprlang — the 0.55 Lua switch only hit the
    # compositor config, not this separate binary.
    xdg.configFile."hypr/xdph.conf".text = ''
      screencopy {
          allow_token_by_default = true
      ${lib.optionalString (
        cfg.shareOutput != null
      ) "    custom_picker_binary = ${sharePicker}/bin/xdph-auto-picker"}
      }
    '';

    wayland.windowManager.hyprland = {
      enable = true;
      package = null;
      portalPackage = null;
      # Hyprland 0.55+ removed the hyprlang parser entirely — the config format
      # is now Lua only (see home/common/programs/hyprland — the whole config
      # below is raw Lua using the hl.* API). home-manager still emits its own
      # systemd-session start hook, so we don't duplicate that here.
      configType = "lua";
      plugins = [ ];
      extraConfig = ''
        local mod = "SUPER"

        -- look & feel / behaviour
        hl.config({
          general = {
            border_size = 1,
            gaps_in = 0,
            gaps_out = 0,
            snap = {
              enabled = true,
              border_overlap = true,
            },
            col = {
              inactive_border = "0x99999999",
              active_border = "0x99999999",
            },
          },

          input = {
            kb_options = "ctrl:nocaps",
            repeat_delay = 150,
            touchpad = {
              natural_scroll = true,
            },
            numlock_by_default = true,
          },

          cursor = {
            no_hardware_cursors = true,
            -- Auto-hide the pointer after 3s of no movement so a parked cursor
            -- doesn't sit on top of a game (visible in the stream too). It
            -- reappears the instant the mouse moves.
            inactive_timeout = 3,
          },

          misc = {
            disable_hyprland_logo = true,
            disable_splash_rendering = true,
            on_focus_under_fullscreen = 2,
          },

          ecosystem = {
            no_update_news = true,
          },

          xwayland = {
            force_zero_scaling = true,
          },

          decoration = {
            blur = {
              enabled = true,
              popups = false,
            },
            shadow = {
              enabled = false,
            },
          },
        })

        -- keep default animations, but speed them all up
        hl.animation({ leaf = "global", enabled = true, speed = 2, bezier = "default" })

        -- environment
        hl.env("GDK_SCALE", "2.0")
        hl.env("XCURSOR_SIZE", "${toString cfg.cursorSize}")
        hl.env("HYPRCURSOR_THEME", "rose-pine-hyprcursor")
        hl.env("HYPRCURSOR_SIZE", "${toString cfg.cursorSize}")
        -- Route Qt6 apps (incl. the xdph screen-share picker) through qt6ct so
        -- the noctalia-generated color scheme actually applies. Without this
        -- var the qt6ct.conf is never read.
        hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

        -- autostart
        hl.on("hyprland.start", function()
          -- Import the Qt theme var too, so the dbus/systemd-activated
          -- xdg-desktop-portal-hyprland (and its share-picker) inherit it.
          hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP QT_QPA_PLATFORMTHEME")
          hl.exec_cmd("hyprctl setcursor Nordzy-cursors ${toString cfg.cursorSize}")
          hl.exec_cmd("hyprsunset")
          hl.exec_cmd("noctalia")
          -- kdeconnectd is only DBus-activated; nothing starts it at login,
          -- so clipboard sync stays dead until the indicator runs.
          hl.exec_cmd("kdeconnect-indicator")
        end)

        -- layer rules
        hl.layer_rule({ match = { namespace = "noctalia-wallpaper" }, blur = true, ignore_alpha = 0.5 })

        -- workspace rules
        hl.workspace_rule({ workspace = "w[t1]", gaps_out = 0, gaps_in = 0 })   -- no gaps when only window
        hl.workspace_rule({ workspace = "w[tg1]", gaps_out = 0, gaps_in = 0 })
        hl.workspace_rule({ workspace = "f[1]", gaps_out = 0, gaps_in = 0 })
        hl.workspace_rule({ workspace = "special:terminal", on_created_empty = "[float; size 1400 1000; center 1] kitty", persistent = false })
        hl.workspace_rule({ workspace = "special:yazi", on_created_empty = "[float; size ${cfg.yaziSize}; center 1] kitty --session sessions/yazi", persistent = false })

        -- window rules
        hl.window_rule({ match = { class = "com.gabm.satty" }, float = true })

        hl.window_rule({ match = { class = "imv" }, float = true, size = "1920 1080", move = "(cursor_x-(window_w*0.5)) (cursor_y-(window_h*0.5))" })
        hl.window_rule({ match = { class = "mpv" }, float = true, size = "1920 1080", move = "(cursor_x-(window_w*0.5)) (cursor_y-(window_h*0.5))" })

        -- webcam overlay (`webcam` command) — small, pinned, bottom-right.
        -- Declared after the mpv class rule so its title match wins.
        hl.window_rule({
          match = { title = "webcam-overlay" },
          float = true,
          size = "360 240",
          move = "100%-380 100%-260",
          pin = true,
          no_initial_focus = true,
          border_size = 0,
        })

        hl.window_rule({ match = { class = "thunar" }, float = true, size = "1800 1200", move = "(cursor_x-(window_w*0.5)) (cursor_y-(window_h*0.5))" })
        hl.window_rule({ match = { class = [[\.blueman-manager-wrapped]] }, float = true, size = "1200 800", move = "(cursor_x-(window_w*0.5)) (cursor_y-(window_h*0.5))" })
        hl.window_rule({ match = { class = [[org\.pulseaudio\.pavucontrol]] }, float = true, size = "1200 1200", move = "(cursor_x-(window_w*0.5)) (cursor_y-(window_h*0.5))" })

        -- wine / game installers (Inno Setup temp windows, e.g. Heroic/GOG).
        -- Their class is the random "setup_*.tmp" filename, so match by suffix.
        hl.window_rule({ match = { class = [[.*\.tmp]] }, float = true, center = true })

        -- metamask
        hl.window_rule({ match = { class = [[chrome-nkbihfbeogaeaoehlefnkodbefgpgknn-.*]] }, float = true })
        -- bitwarden, chrome
        hl.window_rule({ match = { class = [[chrome-nngceckbapebfimnlniiiahkandclblb-.*]] }, float = true })
        -- claude for chrome
        hl.window_rule({ match = { class = [[chrome-fcoeoabgfenejglbffodgkkbkcdhcgfn-.*]] }, float = true, move = "(cursor_x-(window_w*0.5)) (cursor_y-(window_h*0.5))" })

        -- no gaps when only window
        hl.window_rule({ match = { float = false, workspace = "w[t1]" }, border_size = 0, rounding = 0 })
        hl.window_rule({ match = { float = false, workspace = "w[tg1]" }, border_size = 0, rounding = 0 })
        hl.window_rule({ match = { float = false, workspace = "f[1]" }, border_size = 0, rounding = 0 })

        hl.window_rule({ match = { workspace = "special:terminal" }, center = true })
        hl.window_rule({ match = { workspace = "special:yazi" }, center = true })

        -- keybinds
        hl.bind(mod .. " + N", hl.dsp.exec_cmd("noctalia msg panel-toggle control-center"))
        hl.bind(mod .. " + T", hl.dsp.exec_cmd("kitty"))
        hl.bind(mod .. " + V", hl.dsp.window.float({ action = "toggle" }))
        hl.bind(mod .. " + Q", hl.dsp.window.close())
        hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
        hl.bind(mod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "maximized" }))

        -- lock (routes through logind -> hypridle lock_cmd -> hyprlock)
        hl.bind(mod .. " + CTRL + L", hl.dsp.exec_cmd("loginctl lock-session"))

        hl.bind(mod .. " + space", hl.dsp.exec_cmd("noctalia msg panel-toggle launcher"))

        -- printscreen
        hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m region --raw | satty --filename - --output-filename ~/downloads/screenshots/$(date +%Y-%m-%d_%H-%M-%S).png"))
        hl.bind("SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m window --raw | satty --filename - --output-filename ~/downloads/screenshots/$(date +%Y-%m-%d_%H-%M-%S).png"))

        -- move focus with mod + hjkl
        hl.bind(mod .. " + H", hl.dsp.focus({ direction = "left" }))
        hl.bind(mod .. " + J", hl.dsp.focus({ direction = "down" }))
        hl.bind(mod .. " + K", hl.dsp.focus({ direction = "up" }))
        hl.bind(mod .. " + L", hl.dsp.focus({ direction = "right" }))

        -- switch / move-to workspaces 1-6
        for i = 1, 6 do
          hl.bind(mod .. " + " .. i, hl.dsp.focus({ workspace = i }))
          hl.bind(mod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
        end

        -- move active window inside workspace
        hl.bind(mod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
        hl.bind(mod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
        hl.bind(mod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
        hl.bind(mod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))

        -- scroll through workspaces with mod + scroll
        hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
        hl.bind(mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

        -- special workspaces (toggle + recenter in one handler)
        hl.bind(mod .. " + X", function()
          hl.dispatch(hl.dsp.workspace.toggle_special("terminal"))
          hl.dispatch(hl.dsp.window.center())
        end)
        hl.bind(mod .. " + E", function()
          hl.dispatch(hl.dsp.workspace.toggle_special("yazi"))
          hl.dispatch(hl.dsp.window.center())
        end)

        -- volume / brightness (locked so they work on the lock screen; repeat on hold)
        hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
        hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
        hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+"), { locked = true, repeating = true })
        hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeating = true })

        -- media keys (locked)
        hl.bind("XF86AudioMute", hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle"), { locked = true })
        hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("volumectl -m toggle-mute"), { locked = true })
        hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
        hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
        hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })

        -- move/resize windows with mod + LMB/RMB drag
        hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
        hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
      '';
    };

    services.hyprpaper.enable = false;

    # hyprlock: the lock screen, replacing noctalia's built-in locker (which is
    # ugly and — unlike hyprlock — opaque to scripts/lock-state detection).
    # Clean minimal dark look; tweak colours/clock/font to taste. hypridle below
    # drives it (idle + before-sleep), and $mod CTRL+L locks manually.
    programs.hyprlock = {
      enable = true;
      settings = {
        general = {
          hide_cursor = true;
          grace = 0;
          ignore_empty_input = true;
        };

        background = [
          {
            monitor = "";
            color = "rgba(16, 16, 20, 1.0)";
          }
        ];

        label = [
          {
            monitor = "";
            text = "$TIME";
            color = "rgba(230, 230, 240, 1.0)";
            font_size = 92;
            font_family = "monospace";
            position = "0, 110";
            halign = "center";
            valign = "center";
          }
          {
            monitor = "";
            text = ''cmd[update:60000] date +"%A, %d %B"'';
            color = "rgba(170, 170, 185, 1.0)";
            font_size = 20;
            font_family = "monospace";
            position = "0, 30";
            halign = "center";
            valign = "center";
          }
        ];

        input-field = [
          {
            monitor = "";
            size = "320, 56";
            outline_thickness = 2;
            dots_size = 0.26;
            dots_spacing = 0.3;
            dots_center = true;
            outer_color = "rgba(80, 80, 95, 1.0)";
            inner_color = "rgba(30, 30, 38, 1.0)";
            font_color = "rgba(220, 220, 230, 1.0)";
            check_color = "rgba(120, 170, 240, 1.0)";
            fail_color = "rgba(220, 90, 90, 1.0)";
            fail_text = "<i>wrong</i>";
            placeholder_text = "<i>password</i>";
            fade_on_empty = false;
            position = "0, -50";
            halign = "center";
            valign = "center";
          }
        ];
      };
    };

    services.hypridle = {
      enable = true;
      settings = {
        general = {
          after_sleep_cmd = "hyprctl dispatch dpms on";
          before_sleep_cmd = "loginctl lock-session";
          # Must be true on this streaming box. GameMode (via Sunshine/Moonlight)
          # raises a dbus ScreenSaver inhibitor; if one arrives *after* the dpms-off
          # timeout has fired, hypridle's onResumed() sees inhibit_locks > 0 and
          # silently skips the on-resume `dpms on` — leaving every display (and the
          # Moonlight stream) stuck black until a hard power-cycle. Ignoring dbus
          # inhibits keeps the lock count at 0 so resume always turns displays back on.
          ignore_dbus_inhibit = true;
          # guard against launching a second hyprlock over an existing one
          lock_cmd = "pidof hyprlock || hyprlock";
        };
        listener = [
          {
            timeout = 900;
            on-timeout = "loginctl lock-session";
          }
          {
            timeout = 1200;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
        ];
      };
    };
  };
}
