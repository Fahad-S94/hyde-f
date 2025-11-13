function fcd --description 'Fuzzy find and change directory'
    set -l dir (fd --type d | fzf --preview 'eza -l --color=always {}')
    test -n "$dir"; and cd $dir
end
