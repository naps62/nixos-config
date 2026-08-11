{ pkgs, ... }:
let
  # wl-kbptr's OpenCV target detection (the `detect` source used by SUPER+G) is
  # hardcoded for a ~1080p screen and finds almost nothing on a 4K one.
  #
  # src/target_detection.cpp:264 discards any candidate target with
  # `height >= 50 || width >= 500`. Every monitor here is 4K at scale = 1, so an
  # ordinary button or list row is ~50px tall and well over 500px wide — i.e.
  # basically every real control is thrown away for being "too big", and the
  # only survivors are emoji and avatars. Verified on-screen: stock, a full
  # Slack window got ~8 labels, all on images; patched, every channel, tab and
  # button gets one.
  #
  # Doubling the four thresholds (and the dilate kernel that merges glyph edges
  # into word blobs) is exactly the 1080p->4K ratio. None of these are exposed
  # as config options in 0.4.1, so patching is the only way in. Drop this
  # override if upstream makes detection DPI-aware.
  # Second bug, on the rotated monitor (DP-2, transform = 1): the pointer lands
  # in the wrong place because the rotation is applied twice.
  #
  # src/utils_wayland.c move_pointer() takes output->width/height — which come
  # from `xdg_output.logical_size`, i.e. already rotated — and then runs
  # _apply_transform() over them again before motion_absolute(). Hyprland's
  # virtual-pointer also works in logical space, so the second rotation is pure
  # error. Measured: asking for global (4000,1000) on DP-2 landed at
  # (4286,3726); the double-rotation arithmetic predicts (4301,3736).
  #
  # Passing TRANSFORM_NORMAL makes the call a no-op while keeping the (static)
  # function referenced, so no unused-function warning. Only correct for
  # compositors that expect logical coords; fine here, Hyprland-only config.
  wl-kbptr = pkgs.wl-kbptr.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      substituteInPlace src/utils_wayland.c \
        --replace-fail \
          '&x, &y, &output_width, &output_height, state->current_output->transform' \
          '&x, &y, &output_width, &output_height, WL_OUTPUT_TRANSFORM_NORMAL'
      substituteInPlace src/target_detection.cpp \
        --replace-fail \
          'rect.height >= 50 || rect.width >= 500 || rect.height <= 3 ||' \
          'rect.height >= 100 || rect.width >= 1000 || rect.height <= 6 ||' \
        --replace-fail 'rect.width <= 7) {' 'rect.width <= 14) {' \
        --replace-fail 'if (rect.height <= 6) {' 'if (rect.height <= 12) {' \
        --replace-fail 'round(2.5 * scale), round(3.5 * scale)' \
                       'round(5.0 * scale), round(7.0 * scale)'
    '';
  });
in
{
  home.packages = [ wl-kbptr ];

  # wl-kbptr — move/click the pointer with the keyboard. We reorder the label
  # alphabet so the easiest tiles land on the home row, set a monospace label
  # font so labels stay legible over busy backgrounds, and roughly double every
  # size default. Run `wl-kbptr --help-config` for the full option list.
  #
  # The size bump is not taste, it's DPI: every monitor here is 4K at
  # `scale = 1` (see home/*/monitors.nix), and wl-kbptr paints raw cairo onto a
  # layer surface, so it never sees a scale factor — GDK_SCALE only fixes GTK
  # apps. Upstream's defaults are tuned for ~1080p and render half-size here.
  #
  # `label_font_size` is `min proportion max`, evaluated as
  # clamp(area_height * proportion, min, max). In floating/detect mode the
  # detected areas are buttons and icons, i.e. short, so it's the *minimum* that
  # is in force for nearly every label — raising max alone would change nothing.
  xdg.configFile."wl-kbptr/config".text = ''
    [general]
    modes=tile,bisect

    [mode_tile]
    label_symbols=asdfghjklqwertyuiopzxcvbnm
    label_font_family=monospace
    label_font_size=20 50% 120

    [mode_floating]
    label_symbols=asdfghjklqwertyuiopzxcvbnm
    label_font_family=monospace
    label_font_size=28 45% 80

    [mode_bisect]
    label_font_family=monospace
    label_font_size=32
    label_padding=20
    pointer_size=32

    [mode_split]
    pointer_size=32

    [mode_click]
    button=left
  '';

  wayland.windowManager.hyprland.extraConfig = ''
    -- wl-kbptr: keyboard pointer control.
    --
    -- SUPER+G       "vimium for the desktop" — OpenCV detects clickable regions
    --               from a screencopy frame and labels them; type a label and it
    --               moves the pointer to that region's centre and left-clicks.
    --               Needs the HiDPI patch in kbptr.nix to find anything here.
    -- SUPER+SHIFT+G tile -> bisect, for anywhere detection misses. Type the tile
    --               label, then bisect with the home row; g/h/b left/right/middle
    --               click, Enter/Space just parks the cursor, Backspace steps back.
    --
    -- Both need wlr-layer-shell + wlr-virtual-pointer (+ wlr-screencopy for
    -- detect), all of which Hyprland implements.
    -- spelled out rather than reusing the `mod` local from default.nix: both
    -- chunks land in the same hyprland.lua but their relative order isn't pinned.
    -- Guarded with `pidof` the same way hypridle's lock_cmd is. wl-kbptr only
    -- exits on a keypress (main.c sets running=false solely from the keyboard
    -- handler), so an overlay that loses focus before you type a label just sits
    -- there holding an exclusive keyboard grab until it's killed from a shell —
    -- which happened here. The guard stops repeat presses stacking more of them.
    hl.bind("SUPER + G", hl.dsp.exec_cmd("pidof wl-kbptr || wl-kbptr -o modes=floating,click -o mode_floating.source=detect"))
    hl.bind("SUPER + SHIFT + G", hl.dsp.exec_cmd("pidof wl-kbptr || wl-kbptr"))
  '';
}
