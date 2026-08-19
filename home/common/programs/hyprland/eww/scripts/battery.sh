# One JSON object for the panel's battery row. `present: false` on the desktops,
# which have no BAT* at all — the row hides itself on that.

bat=$(find /sys/class/power_supply -maxdepth 1 -name 'BAT*' 2>/dev/null | sort | head -1)

if [ -z "$bat" ]; then
  jq -nc '{ present: false, icon: "", label: "", sub: "" }'
  exit 0
fi

capacity=$(cat "$bat/capacity")
status=$(cat "$bat/status")

if [ "$status" = "Charging" ] || [ "$status" = "Full" ]; then
  icon="󰂄"
elif [ "$capacity" -ge 90 ]; then icon="󰁹"
elif [ "$capacity" -ge 80 ]; then icon="󰂂"
elif [ "$capacity" -ge 70 ]; then icon="󰂁"
elif [ "$capacity" -ge 60 ]; then icon="󰂀"
elif [ "$capacity" -ge 50 ]; then icon="󰁿"
elif [ "$capacity" -ge 40 ]; then icon="󰁾"
elif [ "$capacity" -ge 30 ]; then icon="󰁽"
elif [ "$capacity" -ge 20 ]; then icon="󰁼"
elif [ "$capacity" -ge 10 ]; then icon="󰁻"
else icon="󰁺"
fi

jq -nc \
  --arg icon "$icon" \
  --arg label "$capacity%" \
  --arg sub "$status" \
  '{ present: true, icon: $icon, label: $label, sub: $sub }'
