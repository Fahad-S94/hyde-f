if type -q starship
    starship init fish | source
    set -gx STARSHIP_CONFIG ~/.config/starship/starship.toml
end
