# Toggle the panel on whichever monitor has focus. `eww open --toggle` can't do
# this: it ignores --screen when the window is already open elsewhere, so the
# panel would stay stuck on the monitor it first appeared on.

tray_config="$HOME/.config/waybar-tray/config"
tray_style="$HOME/.config/waybar-tray/style.css"

if eww active-windows | grep -q '^panel'; then
  pkill -f "waybar -c $tray_config" || true
  exec eww close panel
fi

# In case a previous instance was left running (e.g. panel closed by some
# path other than this script or the dashboard's `act` helper).
pkill -f "waybar -c $tray_config" 2>/dev/null || true
setsid --fork waybar -c "$tray_config" -s "$tray_style" >/dev/null 2>&1

screen=$(hyprctl -j monitors | jq -r 'map(select(.focused))[0].id // 0')

exec eww open panel --screen "$screen"
