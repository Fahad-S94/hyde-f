#!/bin/bash
# ~/.config/hypr/scripts/toggle_monitor.sh
# Script to toggle HDMI-A-1 monitor on/off

# Check if HDMI-A-1 is currently active
if hyprctl monitors | grep -q "HDMI-A-1"; then
    # Monitor is active, disable it
    hyprctl keyword monitor "HDMI-A-1,disable"
    # Set DP-1 to primary position (0,0)
    hyprctl keyword monitor "DP-1,1920x1080@143.85,0x0,1"
    # Move all windows from HDMI-A-1 to DP-1 (if any workspace was there)
    hyprctl dispatch moveworkspacetomonitor "1 DP-1" 2>/dev/null || true
    notify-send "Monitor" "HDMI-A-1 disabled" -t 2000
else
    # Monitor is disabled, enable it
    hyprctl keyword monitor "HDMI-A-1,1920x1080@60.00,0x0,1"
    # Adjust DP-1 position to be to the right of HDMI-A-1
    hyprctl keyword monitor "DP-1,1920x1080@143.85,1920x0,1"
    # Move workspace 1 back to HDMI-A-1 (optional)
    hyprctl dispatch moveworkspacetomonitor "1 HDMI-A-1" 2>/dev/null || true
    notify-send "Monitor" "HDMI-A-1 enabled" -t 2000
fi
