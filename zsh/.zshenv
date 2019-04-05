source "$HOME/dotfiles/dotbin/exports"
export HISTFILE="${XDG_DATA_HOME}/zsh/history"
[ ! -f "$HISTFILE" ] && mkdir -p "$(dirname "$HISTFILE")" 2>/dev/null ; touch "$HISTFILE"
export ZDOTDIR="${XDG_CONFIG_HOME}/zsh"
export LSCOLORS=ExFxCxDxBxegedabagacad
