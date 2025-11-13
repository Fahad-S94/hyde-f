set -gx XDG_CONFIG_HOME $HOME/.config
set -gx XDG_DATA_HOME $HOME/.local/share
set -gx XDG_CACHE_HOME $HOME/.cache
set -gx XDG_STATE_HOME $HOME/.local/state

fish_add_path $HOME/.local/bin

set -g fish_history_max 10000
set -gx LESSHISTFILE /tmp/less-hist
set -gx LESS '-R'
set -gx CLICOLOR 1
