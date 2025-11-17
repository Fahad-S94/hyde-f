#!/bin/bash
# Source Hyde environment
[[ "${HYDE_SHELL_INIT}" -ne 1 ]] && eval "$(hyde-shell init)" 2>/dev/null || true

GHOSTTY_THEME="${HOME}/.config/ghostty/theme.conf"
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
    SOURCE_FILE="$KITTY_THEME"
else
    SOURCE_FILE="$KITTY_WALLBASH"
fi

# Verify source file exists
if [ ! -f "$SOURCE_FILE" ]; then
    echo "Warning: Source theme not found at $SOURCE_FILE" >&2
    exit 0
fi

# Extract colors (same as your Alacritty script)
FOREGROUND=$(get_color "foreground" "$SOURCE_FILE")
BACKGROUND=$(get_color "background" "$SOURCE_FILE")
CURSOR=$(get_color "cursor" "$SOURCE_FILE")
CURSOR_TEXT=$(get_color "cursor_text_color" "$SOURCE_FILE" || get_color "cursor_text" "$SOURCE_FILE")
SELECTION_FG=$(get_color "selection_foreground" "$SOURCE_FILE")
SELECTION_BG=$(get_color "selection_background" "$SOURCE_FILE")

# Defaults
[ -z "$FOREGROUND" ] && FOREGROUND="#ffffff"
[ -z "$BACKGROUND" ] && BACKGROUND="#000000"
[ -z "$CURSOR" ] && CURSOR="$FOREGROUND"
[ -z "$SELECTION_FG" ] && SELECTION_FG="$FOREGROUND"
[ -z "$SELECTION_BG" ] && SELECTION_BG="#335577"
if [ "$CURSOR_TEXT" = "background" ] || [ -z "$CURSOR_TEXT" ]; then
    CURSOR_TEXT="$BACKGROUND"
fi

# Extract 0-15 palette
for i in {0..15}; do
    COLOR=$(get_color "color${i}" "$SOURCE_FILE")
    [ -z "$COLOR" ] && COLOR="#808080"
    eval "COLOR${i}='${COLOR}'"
done

# Generate Ghostty theme file
mkdir -p "$(dirname "$GHOSTTY_THEME")"
cat > "$GHOSTTY_THEME" <<CONF
# Auto-generated Ghostty theme from Hyde/Wallbash
# Source: ${SOURCE_FILE}
# Generated: $(date)

background = ${BACKGROUND}
foreground = ${FOREGROUND}
cursor-color = ${CURSOR}
cursor-text = ${CURSOR_TEXT}
selection-background = ${SELECTION_BG}
selection-foreground = ${SELECTION_FG}

palette = 0=${COLOR0}
palette = 1=${COLOR1}
palette = 2=${COLOR2}
palette = 3=${COLOR3}
palette = 4=${COLOR4}
palette = 5=${COLOR5}
palette = 6=${COLOR6}
palette = 7=${COLOR7}
palette = 8=${COLOR8}
palette = 9=${COLOR9}
palette = 10=${COLOR10}
palette = 11=${COLOR11}
palette = 12=${COLOR12}
palette = 13=${COLOR13}
palette = 14=${COLOR14}
palette = 15=${COLOR15}
CONF

# Live reload all running Ghostty instances
pkill -USR1 ghostty 2>/dev/null || true

exit 0
