#!/bin/zsh
# Set colors in terminal
eval $(dircolors -p | sed -e 's/DIR 01;34/DIR 01;36/' | dircolors /dev/stdin)

# Auto correct "cd .." to "cd ../"
zstyle ':completion:*' special-dirs true

# colored completion - use my LS_COLORS
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# Aliases
alias ls="ls --color=auto"
alias ll="ls -alF"

# Command to launch vim/vimlike vim
export EDITOR="vim"

# Stupid alert
alias vmi=$EDITOR
alias viom=$EDITOR

# Other aliases
alias dirs="dirs -v"

autoload -U colors && colors
PROMPT="%{$fg[yellow]%}[%n]%{$reset_color%}%{$fg[blue]%}[%~]%{$reset_color%} %# "
