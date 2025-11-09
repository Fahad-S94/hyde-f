#!/bin/bash

# Reload Alacritty config for all running instances
# Alacritty automatically reloads when config changes, but we can ensure it
pkill -USR1 alacritty 2>/dev/null || true

# Alternative: use alacritty msg if available
if command -v alacritty &> /dev/null; then
    alacritty msg config -w -1 2>/dev/null || true
fi
