#!/bin/bash
# Enhanced random theme script with built-in Alacritty support and random wallpaper
THEME_DIR="$HOME/.config/hyde/themes"
WALLPAPER_SCRIPT="$HOME/.local/lib/hyde/wallpaper.sh"

# Get list of available themes from the themes directory
mapfile -t themes < <(ls -1 "$THEME_DIR")
# Pick a random theme
random_theme=${themes[$RANDOM % ${#themes[@]}]}
echo "Applying theme: $random_theme"

# Apply the theme via hydectl
hydectl theme set "$random_theme"

# Apply random wallpaper (global, using swww backend by default)
if [ -f "$WALLPAPER_SCRIPT" ]; then
	sleep 2 # Brief delay to ensure theme is fully applied
	echo "Applying random wallpaper..."
	"$WALLPAPER_SCRIPT" -r -G
else
	echo "Warning: Wallpaper script not found at $WALLPAPER_SCRIPT"
fi
