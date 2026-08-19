# One JSON object for the panel's bluetooth row. bluetoothctl blocks forever
# instead of erroring when there is no adapter, hence the /sys check + timeouts.

if [ -z "$(find /sys/class/bluetooth -mindepth 1 -maxdepth 1 2>/dev/null)" ]; then
  jq -nc '{ powered: false, icon: "󰂲", label: "No adapter", sub: "" }'
  exit 0
fi

powered=$(timeout 2 bluetoothctl show 2>/dev/null | awk '/Powered:/ { print $2; exit }' || true)

if [ "$powered" != "yes" ]; then
  jq -nc '{ powered: false, icon: "󰂲", label: "Off", sub: "" }'
  exit 0
fi

connected=$(timeout 2 bluetoothctl devices Connected 2>/dev/null | cut -d' ' -f3- | paste -sd', ' - || true)

if [ -n "$connected" ]; then
  jq -nc --arg sub "$connected" '{ powered: true, icon: "󰂱", label: "On", sub: $sub }'
else
  jq -nc '{ powered: true, icon: "󰂯", label: "On", sub: "Nothing connected" }'
fi
