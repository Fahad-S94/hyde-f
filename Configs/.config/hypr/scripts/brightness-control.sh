#!/bin/bash
# Optimized brightness control script for Waybar with minimal lag

# DDCUTIL OPTIMIZATION FLAGS - Critical for performance!
DDCUTIL_FLAGS="--sleep-multiplier 0.1 --skip-ddc-checks --noverify"

# Cache file for bus mappings (to avoid repeated ddcutil detect calls)
CACHE_DIR="$HOME/.cache/brightness-control"
BUS_CACHE="$CACHE_DIR/bus_mappings"

# Auto-detect and cache bus numbers for each output
update_bus_cache() {
	mkdir -p "$CACHE_DIR"

	# Parse ddcutil detect output to map DRM connectors to I2C buses
	# Example: "DRM_connector: card1-DP-1" and "I2C bus: /dev/i2c-6"
	ddcutil detect 2>/dev/null | awk '
		/I2C bus:/ { bus = $NF; gsub(/\/dev\/i2c-/, "", bus) }
		/DRM_connector:/ { 
			connector = $NF
			gsub(/card[0-9]+-/, "", connector)
			if (bus != "" && connector != "") {
				print connector "=" bus
				bus = ""
				connector = ""
			}
		}
	' >"$BUS_CACHE"
}

# Get bus number from cache or detect
get_bus_from_output() {
	local output=$1

	# Check if cache exists, if not create it
	if [ ! -f "$BUS_CACHE" ]; then
		update_bus_cache
	fi

	# Look up bus number in cache
	if [ -f "$BUS_CACHE" ]; then
		local bus=$(grep "^${output}=" "$BUS_CACHE" | cut -d= -f2)
		if [ ! -z "$bus" ]; then
			echo "$bus"
			return
		fi
	fi

	# Fallback to default if not found
	echo "6" # Default to first monitor
}

# Get monitor name from ddcutil (with caching)
get_monitor_name() {
	local bus=$1
	local name_cache="$CACHE_DIR/bus_${bus}_name"

	# Use cached name if available
	if [ -f "$name_cache" ]; then
		cat "$name_cache"
		return
	fi

	# Detect monitor name from ddcutil
	local name=$(ddcutil --bus $bus $DDCUTIL_FLAGS getvcp 10 2>&1 | grep -oP '(?<=Display\s)[^:]+' | head -1)

	if [ -z "$name" ]; then
		# Try to get from EDID
		name=$(ddcutil --bus $bus capabilities 2>&1 | grep -oP '(?<=Model:\s).+' | head -1 | xargs)
	fi

	if [ -z "$name" ]; then
		name="Monitor (Bus $bus)"
	fi

	# Cache the name
	echo "$name" | tee "$name_cache"
}

# State files to track brightness
STATE_DIR="$HOME/.cache/brightness-control"

# Get current brightness (for initial calculation)
get_current_brightness() {
	local bus=$1
	local state_file="$STATE_DIR/bus_${bus}_brightness"

	# First try to read from state file
	if [ -f "$state_file" ]; then
		cat "$state_file"
	else
		# Fall back to ddcutil for initial value (optimized flags)
		CURRENT=$(ddcutil --bus $bus $DDCUTIL_FLAGS getvcp 10 2>/dev/null | sed -n 's/.*current value =[ ]*\([0-9]\+\).*/\1/p')
		if [ ! -z "$CURRENT" ]; then
			echo "$CURRENT"
		else
			echo "50" # Default fallback
		fi
	fi
}

# Handle Waybar modes (auto-detect monitor from environment)
if [[ "$1" == "--waybar"* ]]; then
	BUS=$(get_bus_from_output "$WAYBAR_OUTPUT_NAME")
	STATE_FILE="$STATE_DIR/bus_${BUS}_brightness"
	mkdir -p "$STATE_DIR"

	case "$1" in
	"--waybar")
		# Display mode - output JSON for Waybar
		BRIGHTNESS=$(get_current_brightness $BUS)
		MONITOR_NAME=$(get_monitor_name $BUS)

		# Output JSON with percentage for icon selection and brightness value as text
		echo "{\"text\": \"\", \"tooltip\": \"$MONITOR_NAME: $BRIGHTNESS%\", \"percentage\": $BRIGHTNESS, \"class\": \"brightness\"}"
		exit 0
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
		if [ -f "$STATE_FILE" ]; then
			CURRENT=$(cat "$STATE_FILE")
		else
			CURRENT=$(get_current_brightness $BUS)
		fi

		DIFF=$((50 - CURRENT))
		if [ $DIFF -gt 0 ]; then
			OPERATION="+"
			VALUE=$DIFF
		elif [ $DIFF -lt 0 ]; then
			OPERATION="-"
			VALUE=$((DIFF * -1))
		else
			# Already at 50%, do nothing
			exit 0
		fi
		;;
	esac
else
	# Original mode - manual bus specification OR auto-detect
	if [ "$1" = "--refresh-cache" ]; then
		# Special mode to manually refresh the cache
		update_bus_cache
		echo "Bus cache updated:"
		cat "$BUS_CACHE"
		exit 0
	fi

	BUS=$1
	OPERATION=$2
	VALUE=$3

	if [ $# -ne 3 ]; then
		echo "Usage: $0 <bus_number> <+|-> <value>"
		echo "   or: $0 --waybar|--waybar-up|--waybar-down|--waybar-click"
		echo "   or: $0 --refresh-cache (to update monitor bus mappings)"
		exit 1
	fi

	STATE_FILE="$STATE_DIR/bus_${BUS}_brightness"
	mkdir -p "$STATE_DIR"
fi

# Get current brightness for calculation
CURRENT_BRIGHTNESS=$(get_current_brightness $BUS)

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
