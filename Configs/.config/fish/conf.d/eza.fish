# Eza (better ls) configuration
if type -q eza
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -l --icons --group-directories-first'
    alias la='eza -la --icons --group-directories-first'
    alias tree='eza --tree --icons'
end
