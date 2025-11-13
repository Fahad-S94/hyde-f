set -gx FZF_DEFAULT_OPTS '--height 40% --layout=reverse --border --cycle'
set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
