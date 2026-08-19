# One JSON object per audio node. $1 is "sink" or "source". wpctl prints
# "Volume: 0.45", with " [MUTED]" appended, and errors when there is no node.

case "$1" in
  sink) node="@DEFAULT_AUDIO_SINK@" ;;
  source) node="@DEFAULT_AUDIO_SOURCE@" ;;
  *) echo "usage: audio sink|source" >&2; exit 2 ;;
esac

raw=$(wpctl get-volume "$node" 2>/dev/null || true)

case "$raw" in
  *Volume:*) ;;
  *)
    jq -nc '{ present: false, volume: 0, muted: true, icon: "󰖁" }'
    exit 0
    ;;
esac

volume=$(printf '%s' "$raw" | awk '{ printf "%d", $2 * 100 }')

muted=false
case "$raw" in *MUTED*) muted=true ;; esac

if [ "$1" = "source" ]; then
  if [ "$muted" = true ]; then icon="󰍭"; else icon="󰍬"; fi
elif [ "$muted" = true ]; then icon="󰖁"
elif [ "$volume" -ge 66 ]; then icon="󰕾"
elif [ "$volume" -ge 33 ]; then icon="󰖀"
else icon="󰕿"
fi

jq -nc \
  --argjson volume "$volume" \
  --argjson muted "$muted" \
  --arg icon "$icon" \
  '{ present: true, volume: $volume, muted: $muted, icon: $icon }'
