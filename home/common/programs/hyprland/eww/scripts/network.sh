# One JSON object for the panel's network row. State must match "connected"
# exactly: NetworkManager reports docker0 and br-* as "connected (externally)".

status=$(nmcli -t -f TYPE,STATE,CONNECTION device status 2>/dev/null || true)

# nmcli's terse output backslash-escapes colons inside connection names, so
# rejoin fields 3..NF and unescape rather than taking $3.
pick() {
  printf '%s\n' "$status" | awk -F: -v want="$1" '
    $1 == want && $2 == "connected" {
      name = $3
      for (i = 4; i <= NF; i++) name = name ":" $i
      print name
      exit
    }' | sed 's/\\:/:/g'
}

wifi=$(pick wifi)
ethernet=$(pick ethernet)

if [ -n "$wifi" ]; then
  signal=$(nmcli -t -f IN-USE,SIGNAL dev wifi 2>/dev/null | awk -F: '$1 == "*" { print $2; exit }' || true)

  if [ -z "$signal" ]; then icon="󰤨"
  elif [ "$signal" -ge 75 ]; then icon="󰤨"
  elif [ "$signal" -ge 50 ]; then icon="󰤥"
  elif [ "$signal" -ge 25 ]; then icon="󰤢"
  else icon="󰤟"
  fi

  if [ -n "$signal" ]; then
    sub="Wi-Fi · $signal%"
  else
    sub="Wi-Fi"
  fi

  jq -nc --arg icon "$icon" --arg label "$wifi" --arg sub "$sub" \
    '{ icon: $icon, label: $label, sub: $sub }'
elif [ -n "$ethernet" ]; then
  jq -nc --arg label "$ethernet" '{ icon: "󰈀", label: $label, sub: "Ethernet" }'
else
  jq -nc '{ icon: "󰤭", label: "Offline", sub: "" }'
fi
