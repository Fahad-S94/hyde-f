#!/bin/bash
# Toggle HDMI-A-1 monitor on/off
# Save this as ~/.config/niri/scripts/toggle-hdmi.sh and make it executable

# Get current state of HDMI-A-1
STATE=$(niri msg outputs | grep -A 10 "HDMI-A-1" | grep "Current mode:" | wc -l)

if [ "$STATE" -eq 0 ]; then
	# Monitor is OFF, turn it ON
	# Enable HDMI-A-1 first at position 0,0 (left side)
	niri msg output HDMI-A-1 on
	niri msg output HDMI-A-1 mode 1920x1080@60.000
	niri msg output HDMI-A-1 position 0,0
	# Then move DP-3 to the right at 1920,0
	niri msg output DP-3 position 1920,0
	# notify-send "Monitor" "HDMI monitor enabled (left)" -t 2000
else
	# Monitor is ON, turn it OFF
	# Move DP-3 back to position 0,0 first
	niri msg output DP-3 position 0,0
	# Then turn off HDMI
	niri msg output HDMI-A-1 off
	# notify-send "Monitor" "HDMI monitor disabled" -t 2000
fi
