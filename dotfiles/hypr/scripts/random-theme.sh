#!/bin/bash

# Enhanced random theme script with built-in Alacritty support
THEME_DIR="$HOME/.config/hyde/themes"
ALACRITTY_THEME="$HOME/.config/alacritty/theme.toml"

# Get list of available themes from the themes directory
mapfile -t themes < <(ls -1 "$THEME_DIR")

# Pick a random theme
random_theme=${themes[$RANDOM % ${#themes[@]}]}

echo "Applying theme: $random_theme"

# Apply the theme via hydectl
hydectl theme set "$random_theme"

# Convert Kitty theme to Alacritty format
KITTY_THEME="$THEME_DIR/$random_theme/kitty.theme"

if [ -f "$KITTY_THEME" ]; then
	echo "Converting theme for Alacritty..."

	# Function to extract hex color from kitty config (ignore non-hex values like opacity)
	get_color() {
		local key="$1"
		grep "^$key " "$KITTY_THEME" | awk '{print $2}' | grep "^#" | head -n1
	}

	# Extract colors from kitty theme with fallbacks
	FOREGROUND=$(get_color "foreground")
	BACKGROUND=$(get_color "background")
	CURSOR=$(get_color "cursor")
	CURSOR_TEXT=$(get_color "cursor_text_color")
	SELECTION_FG=$(get_color "selection_foreground")
	SELECTION_BG=$(get_color "selection_background")

	# Set defaults if colors are missing or invalid
	[ -z "$FOREGROUND" ] && FOREGROUND="#ffffff"
	[ -z "$BACKGROUND" ] && BACKGROUND="#000000"
	[ -z "$CURSOR" ] && CURSOR="#ffffff"
	[ -z "$SELECTION_FG" ] && SELECTION_FG="$FOREGROUND" # FIX: Use foreground instead of black
	[ -z "$SELECTION_BG" ] && SELECTION_BG="#ffffff"

	# Handle cursor_text_color = background case BEFORE using it
	if [ "$CURSOR_TEXT" = "background" ] || [ -z "$CURSOR_TEXT" ]; then
		CURSOR_TEXT="$BACKGROUND"
	fi

	# Extract all 16 colors with fallbacks
	COLOR0=$(get_color "color0")
	[ -z "$COLOR0" ] && COLOR0="#000000"
	COLOR1=$(get_color "color1")
	[ -z "$COLOR1" ] && COLOR1="#ff0000"
	COLOR2=$(get_color "color2")
	[ -z "$COLOR2" ] && COLOR2="#00ff00"
	COLOR3=$(get_color "color3")
	[ -z "$COLOR3" ] && COLOR3="#ffff00"
	COLOR4=$(get_color "color4")
	[ -z "$COLOR4" ] && COLOR4="#0000ff"
	COLOR5=$(get_color "color5")
	[ -z "$COLOR5" ] && COLOR5="#ff00ff"
	COLOR6=$(get_color "color6")
	[ -z "$COLOR6" ] && COLOR6="#00ffff"
	COLOR7=$(get_color "color7")
	[ -z "$COLOR7" ] && COLOR7="#ffffff"
	COLOR8=$(get_color "color8")
	[ -z "$COLOR8" ] && COLOR8="#808080"
	COLOR9=$(get_color "color9")
	[ -z "$COLOR9" ] && COLOR9="#ff0000"
	COLOR10=$(get_color "color10")
	[ -z "$COLOR10" ] && COLOR10="#00ff00"
	COLOR11=$(get_color "color11")
	[ -z "$COLOR11" ] && COLOR11="#ffff00"
	COLOR12=$(get_color "color12")
	[ -z "$COLOR12" ] && COLOR12="#0000ff"
	COLOR13=$(get_color "color13")
	[ -z "$COLOR13" ] && COLOR13="#ff00ff"
	COLOR14=$(get_color "color14")
	[ -z "$COLOR14" ] && COLOR14="#00ffff"
	COLOR15=$(get_color "color15")
	[ -z "$COLOR15" ] && COLOR15="#ffffff"

	# Create alacritty config directory if it doesn't exist
	mkdir -p "$HOME/.config/alacritty"

	# Generate Alacritty TOML config
	cat >"$ALACRITTY_THEME" <<EOF
# Auto-generated from Hyde Kitty theme: $random_theme
# Generated on $(date)

[colors.primary]
background = '${BACKGROUND}'
foreground = '${FOREGROUND}'

[colors.cursor]
cursor = '${CURSOR}'
text = '${CURSOR_TEXT}'

[colors.selection]
background = '${SELECTION_BG}'
text = '${SELECTION_FG}'

[colors.normal]
black = '${COLOR0}'
red = '${COLOR1}'
green = '${COLOR2}'
yellow = '${COLOR3}'
blue = '${COLOR4}'
magenta = '${COLOR5}'
cyan = '${COLOR6}'
white = '${COLOR7}'

[colors.bright]
black = '${COLOR8}'
red = '${COLOR9}'
green = '${COLOR10}'
yellow = '${COLOR11}'
blue = '${COLOR12}'
magenta = '${COLOR13}'
cyan = '${COLOR14}'
white = '${COLOR15}'
EOF

	echo "Alacritty theme updated: $ALACRITTY_THEME"
else
	echo "Warning: Could not find kitty theme file for $random_theme"
fi
