if type -q atuin
    set -gx ATUIN_NOBIND true
    atuin init fish | source

    # Smart up arrow function that checks if we're in completion menu
    function _smart_atuin_up
        # Check if we're in a completion menu
        if commandline --paging-mode
            # In completion menu - navigate up in the menu
            up-or-search
        else
            # Not in completion menu - use atuin
            _atuin_search
        end
    end

    # Bind up arrow to smart function
    bind \e\[A _smart_atuin_up
    bind \eOA _smart_atuin_up
end
