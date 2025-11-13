# ============================================
# User Configuration
# ============================================

# Environment Variables
set -gx EDITOR helix
set -gx VISUAL helix

# Ctrl+Up: Move to beginning of line
bind \e\[1\;5A beginning-of-line

# Ctrl+Down: Move to end of line
bind \e\[1\;5B end-of-line

# Custom Aliases
alias hx='helix'
alias c='clear'
alias mkdir='mkdir -p'

# Git Aliases
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit -v'
alias gca='git commit -v -a'
alias gcam='git commit -a -m'
alias gco='git checkout'
alias gd='git diff'
alias gl='git pull'
alias gp='git push'
alias gst='git status'
alias glog='git log --oneline --decorate --graph'

# Directory Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'

# Package Manager
alias in='yay -S'
alias un='yay -Rns'
alias up='yay -Syu'
alias pl='yay -Q'
alias pa='yay -Ss'

# Abbreviations
abbr -a gst git status
abbr -a gco git checkout
abbr -a gcm git commit -m
abbr -a gaa git add --all
abbr -a gp git push
abbr -a gl git pull

# Custom Abbreviations (from zsh-abbr)
abbr -a c clear
abbr -a nv nvim
abbr -a pi "paru -S --skipreview"
abbr -a pin "paru -S --noconfirm --skipreview --removemake --cleanafter --needed --sudoloop"
abbr -a q exit
abbr -a sn "sudo nano"
abbr -a spi "sudo pacman -S"
abbr -a spr "sudo pacman -Rns"
abbr -a sv "sudo -E nvim"
abbr -a yi "yay -S"
abbr -a yin "yay -S --noconfirm --cleanafter --removemake --needed --sudoloop"
