function ffe --description 'Fuzzy find and edit file'
    set -l file (fd --type f | fzf --preview 'bat --color=always --style=plain {}')
    test -n "$file"; and $EDITOR $file
end
