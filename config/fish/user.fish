# ============================================
# User Configuration
# ============================================

# Environment Variables
set -gx EDITOR helix
set -gx VISUAL helix

#CUSTOM KEYBINDS
bind ctrl-up beginning-of-line
bind ctrl-down end-of-line
# bind ctrl-up 'commandline -f beginning-of-line; commandline -f up-line'
# bind ctrl-down 'commandline -f end-of-line; commandline -f down-line'
bind ctrl-alt-backspace kill-whole-line

# Custom Aliases
alias hx='helix'
alias nv="nvim"
alias mkdir='mkdir -p'

# Directory Navigation
abbr -a .. "cd .."
abbr -a ... "cd ../.."
abbr -a .3 "cd ../../.."
abbr -a .4 "cd ../../../.."
abbr -a .5 "cd ../../../../.."

# Abbreviations
abbr -a g git
abbr -a ga "git add"
abbr -a gaa "git add --all"
abbr -a gc "git commit -v"
abbr -a gca "git commit -v -a"
abbr -a gcam "git commit -a -m"
abbr -a gcm "git commit -m"
abbr -a gco "git checkout"
abbr -a gd "git diff"
abbr -a gl "git pull"
abbr -a gp "git push"
abbr -a gst "git status"
abbr -a glog "git log --oneline --decorate --graph"

# Custom Abbreviations (from zsh-abbr)
abbr -a c clear
abbr -a pi "paru -S --skipreview"
abbr -a pir "paru -Rns --skipreview"
abbr -a pin "paru -S --noconfirm --skipreview --removemake --cleanafter --needed --sudoloop"
abbr -a pinr "paru -Rns --noconfirm --skipreview --removemake --cleanafter --sudoloop"
abbr -a q exit
abbr -a sn "sudo nano"
abbr -a spi "sudo pacman -S"
abbr -a spr "sudo pacman -Rns"
abbr -a sv "sudo -E nvim"
# abbr -a yi "yay -S"
# abbr -a yir "yay -Rns -S"
# abbr -a yin "yay -S --noconfirm --cleanafter --removemake --needed --sudoloop"
# abbr -a yinr "yay -Rns --noconfirm --removemake --cleanafter --sudoloop"
