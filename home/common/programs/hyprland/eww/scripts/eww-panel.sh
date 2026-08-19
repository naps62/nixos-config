# Toggle the panel on whichever monitor has focus. `eww open --toggle` can't do
# this: it ignores --screen when the window is already open elsewhere, so the
# panel would stay stuck on the monitor it first appeared on.

if eww active-windows | grep -q '^panel'; then
  exec eww close panel
fi

screen=$(hyprctl -j monitors | jq -r 'map(select(.focused))[0].id // 0')

exec eww open panel --screen "$screen"
