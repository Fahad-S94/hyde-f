#!/bin/bash
# Optimized brightness control script for Waybar with minimal lag

# DDCUTIL OPTIMIZATION FLAGS - Critical for performance!
DDCUTIL_FLAGS="--sleep-multiplier 0.1 --skip-ddc-checks --noverify"

# Function to map Hyprland output names to ddcutil bus numbers
get_bus_from_output() {
	case "$1" in
	"DP-1") echo "3" ;;     # MSI G271
	"HDMI-A-1") echo "4" ;; # AOC 2752H
	*) echo "3" ;;          # Default to main monitor
	esac
}

# Handle Waybar modes (auto-detect monitor from environment)
if [[ "$1" == "--waybar"* ]]; then
	BUS=$(get_bus_from_output "$WAYBAR_OUTPUT_NAME")

	case "$1" in
	"--waybar")
		# Display mode - output JSON for Waybar without icons
		;;
	"--waybar-up")
		# Scroll up - increase brightness
		OPERATION="+"
		VALUE=5
		;;
	"--waybar-down")
		# Scroll down - decrease brightness
		OPERATION="-"
		VALUE=5
		;;
	"--waybar-click")
		# Click - set to 50% (calculate difference)
		STATE_DIR="$HOME/.cache/brightness-control"
		STATE_FILE="$STATE_DIR/bus_${BUS}_brightness"
		mkdir -p "$STATE_DIR"

		if [ -f "$STATE_FILE" ]; then
			CURRENT=$(cat "$STATE_FILE")
		else
			CURRENT=$(ddcutil --bus $BUS getvcp 10 2>/dev/null | sed -n 's/.*current value =[ ]*\([0-9]\+\).*/\1/p')
			if [ -z "$CURRENT" ]; then
				CURRENT=50
			fi
		fi

		DIFF=$((50 - CURRENT))
		if [ $DIFF -gt 0 ]; then
			OPERATION="+"
			VALUE=$DIFF
		elif [ $DIFF -lt 0 ]; then
			OPERATION="-"
			VALUE=$((DIFF * -1))
		else
			# Already at 50%, do nothing for display mode
			if [ "$1" = "--waybar" ]; then
				BRIGHTNESS=50
			else
				exit 0
			fi
		fi
		;;
	esac
else
	# Original mode - manual bus specification
	BUS=$1
	OPERATION=$2
	VALUE=$3

	if [ $# -ne 3 ]; then
		echo "Usage: $0 <bus_number> <+|-> <value>"
		echo "   or: $0 --waybar|--waybar-up|--waybar-down|--waybar-click"
		exit 1
	fi
fi

# Get monitor name based on bus number
get_monitor_name() {
	case $1 in
	6) echo "MSI" ;; # Bus 6 - MSI G271 (DP-1)
	7) echo "AOC" ;; # Bus 7 - AOC 2752H (HDMI-A-1)
	*) echo "Monitor (Bus $1)" ;;
	esac
}

# State files to track brightness
STATE_DIR="$HOME/.cache/brightness-control"
STATE_FILE="$STATE_DIR/bus_${BUS}_brightness"

# Create state directory if it doesn't exist
mkdir -p "$STATE_DIR"

# Get current brightness (for initial calculation)
get_current_brightness() {
	# First try to read from state file
	if [ -f "$STATE_FILE" ]; then
		cat "$STATE_FILE"
	else
		# Fall back to ddcutil for initial value (optimized flags)
		CURRENT=$(ddcutil --bus $BUS $DDCUTIL_FLAGS getvcp 10 2>/dev/null | sed -n 's/.*current value =[ ]*\([0-9]\+\).*/\1/p')
		if [ ! -z "$CURRENT" ]; then
			echo "$CURRENT"
		else
			echo "50" # Default fallback
		fi
	fi
}

# If this is just a Waybar display request
if [ "$1" = "--waybar" ]; then
	BRIGHTNESS=$(get_current_brightness)
	MONITOR_NAME=$(get_monitor_name $BUS)

	# Output JSON with empty text, but tooltip with monitor and brightness
	echo "{\"text\": \"\", \"tooltip\": \"$MONITOR_NAME: $BRIGHTNESS%\", \"percentage\": $BRIGHTNESS, \"class\": \"brightness\"}"
	exit 0
fi

# Rest of your existing brightness control logic for actual changes...
CURRENT_BRIGHTNESS=$(get_current_brightness)

if [ "$OPERATION" = "+" ]; then
	NEW_BRIGHTNESS=$((CURRENT_BRIGHTNESS + VALUE))
elif [ "$OPERATION" = "-" ]; then
	NEW_BRIGHTNESS=$((CURRENT_BRIGHTNESS - VALUE))
else
	echo "Invalid operation. Use + or -"
	exit 1
fi

# Clamp brightness between 0 and 100
if [ $NEW_BRIGHTNESS -lt 0 ]; then
	NEW_BRIGHTNESS=0
elif [ $NEW_BRIGHTNESS -gt 100 ]; then
	NEW_BRIGHTNESS=100
fi

# Save new brightness to state file IMMEDIATELY
echo "$NEW_BRIGHTNESS" >"$STATE_FILE"

# Get monitor name
MONITOR_NAME=$(get_monitor_name $BUS)

# Show notification immediately with calculated brightness
BAR_LENGTH=12
FILLED_LENGTH=$((NEW_BRIGHTNESS * BAR_LENGTH / 100))

# Create visual bar
BAR=""
for ((i = 0; i < $FILLED_LENGTH; i++)); do
	BAR+="█"
done
for ((i = $FILLED_LENGTH; i < $BAR_LENGTH; i++)); do
	BAR+="░"
done

# Send notification immediately
notify-send -t 500 -h string:x-canonical-private-synchronous:brightness \
	"🔆 $MONITOR_NAME Brightness" \
	"<b>${BAR} ${NEW_BRIGHTNESS}%</b>"

# Apply brightness change with OPTIMIZED FLAGS (fire and forget)
(ddcutil --bus $BUS $DDCUTIL_FLAGS setvcp 10 $OPERATION $VALUE &) 2>/dev/null

# Optional: Sync with actual brightness in background after a delay
(
	sleep 3
	ACTUAL_BRIGHTNESS=$(ddcutil --bus $BUS $DDCUTIL_FLAGS getvcp 10 2>/dev/null | sed -n 's/.*current value =[ ]*\([0-9]\+\).*/\1/p')
	if [ ! -z "$ACTUAL_BRIGHTNESS" ] && [ "$ACTUAL_BRIGHTNESS" != "$NEW_BRIGHTNESS" ]; then
		echo "$ACTUAL_BRIGHTNESS" >"$STATE_FILE"
	fi
) &
