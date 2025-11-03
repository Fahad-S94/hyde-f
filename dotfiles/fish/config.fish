# ~/.config/fish/config.fish
# Fast and modern Fish configuration

if status is-interactive
    # ============================================
    # PERFORMANCE: Disable greeting for faster startup
    # ============================================
    set -g fish_greeting

    # ============================================
    # ENVIRONMENT VARIABLES
    # ============================================
    # Editor
    set -gx EDITOR nvim
    set -gx VISUAL nvim

    # XDG Base Directory
    set -gx XDG_CONFIG_HOME $HOME/.config
    set -gx XDG_CACHE_HOME $HOME/.cache
    set -gx XDG_DATA_HOME $HOME/.local/share

    # Path additions (only if directories exist - faster)
    fish_add_path -g $HOME/.local/bin
    fish_add_path -g $HOME/.cargo/bin

    # ============================================
    # MODERN CLI TOOLS (bat, eza, etc)
    # ============================================
    # bat (better cat)
    if command -q bat
        set -gx BAT_THEME "Catppuccin Mocha"
        alias cat='bat --paging=never'
        alias less='bat'
    end

    # eza (better ls)
    if command -q eza
        alias ls='eza --icons --group-directories-first'
        alias ll='eza -l --icons --group-directories-first --git'
        alias la='eza -la --icons --group-directories-first --git'
        alias lt='eza --tree --level=2 --icons'
    end

    # fd (better find)
    if command -q fd
        alias find='fd'
    end

    # ripgrep (better grep)
    if command -q rg
        alias grep='rg'
    end

    # zoxide (smart cd - very fast)
    if command -q zoxide
        zoxide init fish | source
        alias cd='z'
    end

    # ============================================
    # ATUIN (shell history sync - load last for speed)
    # ============================================
    # Atuin is loaded last because it's slightly heavier
    # but the speed impact is minimal and worth it
    if command -q atuin
        atuin init fish | source

        # Optional: Customize atuin behavior
        set -gx ATUIN_NOBIND true # Disable default bindings if you want custom ones
        # Bind Ctrl+R for history search (default is up arrow)
        bind \cr _atuin_search
        bind -M insert \cr _atuin_search
    end

    # ============================================
    # PROMPT (Starship - fast and beautiful)
    # ============================================
    # Starship should be last for best performance
    if command -q starship
        starship init fish | source
    end
end
