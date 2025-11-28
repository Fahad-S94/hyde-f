#!/bin/bash

# Source Hyde environment
[[ "${HYDE_SHELL_INIT}" -ne 1 ]] && eval "$(hyde-shell init)" 2>/dev/null || true

ALACRITTY_THEME="${HOME}/.config/alacritty/theme.toml"
KITTY_WALLBASH="${HOME}/.config/kitty/theme.conf"
HYDE_THEME="${HYDE_THEME:-$(cat ~/.cache/hyde/landing.theme 2>/dev/null)}"
THEME_DIR="${HOME}/.config/hyde/themes"
KITTY_THEME="${THEME_DIR}/${HYDE_THEME}/kitty.theme"

# Check wallbash mode (0=theme, 1=auto, 2=dark, 3=light)
enableWallDcol="${enableWallDcol:-0}"

# Function to extract hex color
get_color() {
    local key="$1"
    local file="$2"
    grep "^${key}" "$file" | awk '{print $2}' | grep "^#" | head -n1
}

# Determine source based on wallbash mode
if [ "$enableWallDcol" -eq 0 ]; then
    # Theme mode - use static kitty.theme
    SOURCE_FILE="$KITTY_THEME"
else
    # Auto/Dark/Light mode - use wallbash-generated kitty theme
    SOURCE_FILE="$KITTY_WALLBASH"
fi

# Verify source file exists
if [ ! -f "$SOURCE_FILE" ]; then
    echo "Warning: Source theme not found at $SOURCE_FILE" >&2
    exit 0
fi

# Extract colors from source
FOREGROUND=$(get_color "foreground" "$SOURCE_FILE")
BACKGROUND=$(get_color "background" "$SOURCE_FILE")
CURSOR=$(get_color "cursor" "$SOURCE_FILE")
CURSOR_TEXT=$(get_color "cursor_text_color" "$SOURCE_FILE")
SELECTION_FG=$(get_color "selection_foreground" "$SOURCE_FILE")
SELECTION_BG=$(get_color "selection_background" "$SOURCE_FILE")

# Set defaults if missing
[ -z "$FOREGROUND" ] && FOREGROUND="#ffffff"
[ -z "$BACKGROUND" ] && BACKGROUND="#000000"
[ -z "$CURSOR" ] && CURSOR="$FOREGROUND"
[ -z "$SELECTION_FG" ] && SELECTION_FG="$FOREGROUND"
[ -z "$SELECTION_BG" ] && SELECTION_BG="#ffffff"

# Handle special cursor_text values
if [ "$CURSOR_TEXT" = "background" ] || [ -z "$CURSOR_TEXT" ]; then
    CURSOR_TEXT="$BACKGROUND"
fi

# Extract all 16 colors
for i in {0..15}; do
    COLOR=$(get_color "color${i}" "$SOURCE_FILE")
    [ -z "$COLOR" ] && COLOR="#808080"
    eval "COLOR${i}='${COLOR}'"
done

# Generate Alacritty TOML config
cat > "$ALACRITTY_THEME" <<TOML
# Auto-generated from Hyde Kitty theme
# Mode: $([ "$enableWallDcol" -eq 0 ] && echo "Static Theme" || echo "Wallbash Auto")
# Source: ${SOURCE_FILE}
# Generated: $(date)

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
TOML

exit 0
