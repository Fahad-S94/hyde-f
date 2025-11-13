function _smart_up_arrow
    # Get current command line buffer and cursor position
    set -l cmd (commandline)
    set -l cursor_pos (commandline -C)
    set -l cmd_length (string length -- $cmd)
    
    # If there's text AND cursor is NOT at the end
    if test -n "$cmd" -a $cursor_pos -ne $cmd_length
        # Move to beginning of line
        commandline -f beginning-of-line
    else
        # If line is empty OR cursor is at the end, trigger atuin
        _atuin_search
    end
end
