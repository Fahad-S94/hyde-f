if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Load user customizations
if test -f ~/.config/fish/user.fish
    source ~/.config/fish/user.fish
end
