#!/bin/bash
# Ultra-optimized ddcutil brightness control - minimal lag

# CRITICAL: Even more aggressive optimization
DDCUTIL_FLAGS="--sleep-multiplier 0.05 --skip-ddc-checks --noverify --force-slave-address"

# Cache everything
CACHE_DIR="$HOME/.cache/brightness-control"
BUS_CACHE="$CACHE_DIR/bus_mappings"
STATE_DIR="$HOME/.cache/brightness-control"

# OPTIMIZATION: Keep bus number in memory if possible
if [ -z "$BRIGHTNESS_BUS_CACHE" ]; then
    export BRIGHTNESS_BUS_CACHE_LOADED=0
fi

update_bus_cache() {
    mkdir -p "$CACHE_DIR"
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

get_bus_from_output() {
    local output=$1

    if [ ! -f "$BUS_CACHE" ]; then
        update_bus_cache
    fi

    if [ -f "$BUS_CACHE" ]; then
        local bus=$(grep "^${output}=" "$BUS_CACHE" | cut -d= -f2)
        if [ ! -z "$bus" ]; then
            echo "$bus"
            return
        fi

        local first_bus=$(head -1 "$BUS_CACHE" | cut -d= -f2)
        if [ ! -z "$first_bus" ]; then
            echo "$first_bus"
            return
        fi
    fi

    echo "3"
}

get_monitor_name() {
    local bus=$1
    local name_cache="$CACHE_DIR/bus_${bus}_name"

    if [ -f "$name_cache" ]; then
        cat "$name_cache"
        return
    fi

    local name=$(ddcutil --bus $bus $DDCUTIL_FLAGS getvcp 10 2>&1 | grep -oP '(?<=Display\s)[^:]+' | head -1)

    if [ -z "$name" ]; then
        name=$(ddcutil --bus $bus capabilities 2>&1 | grep -oP '(?<=Model:\s).+' | head -1 | xargs)
    fi

    if [ -z "$name" ]; then
        name="Monitor"
    fi

    echo "$name" | tee "$name_cache"
}

get_current_brightness() {
    local bus=$1
    local state_file="$STATE_DIR/bus_${bus}_brightness"

    if [ -f "$state_file" ]; then
        cat "$state_file"
    else
        CURRENT=$(ddcutil --bus $bus $DDCUTIL_FLAGS getvcp 10 2>/dev/null | sed -n 's/.*current value =[ ]*\([0-9]\+\).*/\1/p')
        if [ ! -z "$CURRENT" ]; then
            echo "$CURRENT"
        else
            echo "50"
        fi
    fi
}

# Waybar modes
if [[ "$1" == "--waybar"* ]]; then
    BUS=$(get_bus_from_output "$WAYBAR_OUTPUT_NAME")
    STATE_FILE="$STATE_DIR/bus_${BUS}_brightness"
    mkdir -p "$STATE_DIR"

    case "$1" in
        "--waybar")
            BRIGHTNESS=$(get_current_brightness $BUS)
            MONITOR_NAME=$(get_monitor_name $BUS)
            echo "{\"text\": \"\", \"tooltip\": \"$MONITOR_NAME: $BRIGHTNESS%\", \"percentage\": $BRIGHTNESS, \"class\": \"brightness\"}"
            exit 0
            ;;
        "--waybar-up")
            OPERATION="+"
            VALUE=5
            ;;
        "--waybar-down")
            OPERATION="-"
            VALUE=5
            ;;
        "--waybar-click")
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
                exit 0
            fi
            ;;
    esac
else
    if [ "$1" = "--refresh-cache" ]; then
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
        echo "   or: $0 --refresh-cache"
        exit 1
    fi

    STATE_FILE="$STATE_DIR/bus_${BUS}_brightness"
    mkdir -p "$STATE_DIR"
fi

CURRENT_BRIGHTNESS=$(get_current_brightness $BUS)

if [ "$OPERATION" = "+" ]; then
    NEW_BRIGHTNESS=$((CURRENT_BRIGHTNESS + VALUE))
elif [ "$OPERATION" = "-" ]; then
    NEW_BRIGHTNESS=$((CURRENT_BRIGHTNESS - VALUE))
else
    echo "Invalid operation. Use + or -"
    exit 1
fi

[ $NEW_BRIGHTNESS -lt 0 ] && NEW_BRIGHTNESS=0
[ $NEW_BRIGHTNESS -gt 100 ] && NEW_BRIGHTNESS=100

# Save IMMEDIATELY
echo "$NEW_BRIGHTNESS" >"$STATE_FILE"

# OPTIMIZATION: Skip monitor name lookup for notifications to save time
# Use cached name or just "Monitor"
if [ -f "$CACHE_DIR/bus_${BUS}_name" ]; then
    MONITOR_NAME=$(cat "$CACHE_DIR/bus_${BUS}_name")
else
    MONITOR_NAME="Monitor"
fi

# Faster bar generation
BAR_LENGTH=7
FILLED_LENGTH=$((NEW_BRIGHTNESS * BAR_LENGTH / 100))
BAR=$(printf '█%.0s' $(seq 1 $FILLED_LENGTH))$(printf '░%.0s' $(seq 1 $((BAR_LENGTH - FILLED_LENGTH))))

# Send notification FIRST (don't wait for ddcutil)
notify-send -t 500 -h string:x-canonical-private-synchronous:brightness \
    "🔆 $MONITOR_NAME" \
    "<b>${BAR} ${NEW_BRIGHTNESS}%</b>" &

# CRITICAL: Use absolute value change instead of relative (+/-)
# This is MUCH faster than relative changes
(ddcutil --bus $BUS $DDCUTIL_FLAGS setvcp 10 $NEW_BRIGHTNESS 2>&1 | grep -v "DDC communication failed" &)

# Optional background sync (disabled by default for speed)
# Uncomment if you want state file to reflect actual hardware value
(
    sleep 3
    ACTUAL=$(ddcutil --bus $BUS $DDCUTIL_FLAGS getvcp 10 2>/dev/null | sed -n 's/.*current value =[ ]*\([0-9]\+\).*/\1/p')
    [ ! -z "$ACTUAL" ] && echo "$ACTUAL" >"$STATE_FILE"
) &
