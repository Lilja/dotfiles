#!/bin/bash

# load the colors
. ~/.dotbin/colors.sh

# load the git prompt
. ~/.dotbin/git-prompt.sh
PS1="${GREEN}\u@\h${NC} ${MAGNETA}\w${NC}${CYAN}\$(__git_ps1)${NC} \$ "
