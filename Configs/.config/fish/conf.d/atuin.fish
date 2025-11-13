set -gx ATUIN_NOBIND true
atuin init fish | source

# Bind up arrow to smart function (moves to beginning OR triggers atuin)
bind \e\[A _smart_up_arrow
bind \eOA _smart_up_arrow

# Down arrow uses default behavior (normal history navigation)
