# Atuin initialization and key binding override
if command -v atuin &>/dev/null; then
    # Initialize atuin with up arrow disabled
    eval "$(atuin init zsh)"
    
    # eval "$(atuin init zsh --disable-up-arrow)"
    
    _up_arrow_custom() {
        if [[ -n "$BUFFER" ]] && [[ $CURSOR -ne ${#BUFFER} ]]; then
            # If there's text AND cursor is NOT at the end, move to beginning
            zle beginning-of-line
        else
            # If line is empty OR cursor is at the end, browse history
            # zle up-line-or-history
            zle atuin-search
        fi
    }
    zle -N _up_arrow_custom
    #
    # # Keybindings
    bindkey '^[OA' _up_arrow_custom
    # bindkey '^[OB' atuin-search
fi
