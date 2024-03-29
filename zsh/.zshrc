# Detect macos/linux
if [ `uname` = "Darwin" ]; then
    export OSX=1
elif [ `uname` = "Linux" ]; then
    export LINUX=1
fi
##############
# Options
##############
# Don't beep, ever
setopt NO_BEEP

# If we do rm *, warn about doing so
setopt RM_STAR_WAIT

# Set cd = pushd
setopt AUTO_PUSHD

# pushd doesn't print directory stack
setopt PUSHD_SILENT

# I dno't nead "autocorrect'!
setopt CORRECT

# Do you have a command that you don't really want to execute, yet?
# Type # infront of it and use it for later.
setopt INTERACTIVE_COMMENTS

##############
# History
##############
# Set distinct up and down arrow history
setopt HIST_IGNORE_ALL_DUPS

# Append the history, don't replace
setopt APPEND_HISTORY

# After executing a command, add it right after instead of when the shell is closed.
setopt INC_APPEND_HISTORY

# Save information of the command in the history
# : <begining time>:<elapsed seconds>;<command>
setopt EXTENDED_HISTORY

# Disable history expansion
# https://unix.stackexchange.com/questions/33339/cant-use-exclamation-mark-in-bash
set +H

# Number of entries a history file can have
SAVEHIST=100000
HISTSIZE=100000

##############
# Alias
############

# Load alias from disk
[ -f "${DOTDIR}/dotbin/aliases" ] && { . "${DOTDIR}/dotbin/aliases" ; }

# Local, untouched by git configuration.
[ -f "${ZDOTDIR}/.zshrc.local" ] && { . "${ZDOTDIR}/.zshrc.local"; }
#############
# Completion
############


##############
# Prompt
##############

# Load color variable fg-array and the reset color variable.
autoload -U colors && colors

# Set prompt substitue for running subshells in the prompt.
setopt PROMPT_SUBST

function show_or_hide_git_stuff {
	git_branch=""

	# Get status
	git_status="$(git status 2>/dev/null)"
	if [ -n "$git_status" ]
	then
		if [[ ! $git_status =~ 'Initial commit' ]]; then
			color=""
			# It's a git branch
			git_branch=$(git rev-parse --abbrev-ref HEAD)

			# Detached?
			detached=$(echo "$git_status" | grep detached )
			is_detached=0

			if [ $(echo "$detached" | wc -w ) -ge 1 ]; then # give detached more priority
				git_branch=":"$(echo "$detached"| awk '{print $4;}')
				is_detached=1
			fi

			# Coloring
			# if output of git status -s is empty, untracked.
			if [ $is_detached -eq 1 ]; # give detached more priority
			then
				color="$fg[red]"
			elif [ ! -n "$(git status -s)" ]; # Green if no untracked changes
			then
				color="$fg[green]"
			else
				# Otherwise, assume modified
				# Yellow for untracked changes
				color="$fg[yellow]"
			fi
			if [ "$1" = "on" ] ; then
				git_branch=" on %{$color%}$git_branch%{$reset_color%}"
			elif [ "$1" = "square" ] ; then
				git_branch=" (%{$color%}$git_branch%{$reset_color%})"
			fi
		else
			git_branch=" %{$fg[green]%}Inited%{$reset_color%}"
		fi
	fi
	echo "$git_branch"
}
# Load Z
[ -f "$DOTBIN/z.sh" ] && . "$DOTBIN/z.sh"

# square_prompt_git="%{$fg[green]%}[%n]%{$reset_color%}%{$fg[magenta]%}[%~]%{$reset_color%}\$(show_or_hide_git_stuff square) %# "
text_prompt_bold_git="%{$fg[green]%}%B%n%b%{$reset_color%} in %{$fg[cyan]%}%B%~%b%{$reset_color%}%B\$(show_or_hide_git_stuff on)%b λ "

# PROMPT=$square_prompt_git
PROMPT=$text_prompt_bold_git

fancy-ctrl-z () {
	if [[ $#BUFFER -eq 0 ]]; then
		BUFFER="fg"
		zle accept-line
	else
		zle push-input
		zle clear-screen
	fi
}

##############
# Keybindings
##############
zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z

# Shift tab to go back in shift com
bindkey '^[[Z' reverse-menu-complete

##############
# Autocompletion
##############
autoload -U compinit && compinit
zmodload -i zsh/complist

zstyle ':completion:*' special-dirs true

##############
# Keyboard layout
##############

# Set swedish layout.
if [ ! -z "${DISPLAY:+foo}" ]; then
    which setxkbmap >/dev/null && setxkbmap se
fi

if [ -d "$HOME/.nvm" ]; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" --no-use  # This loads nvm
fi

if [ -z $OSX ]; then
    export PATH="/usr/local/opt/curl/bin:$PATH"
fi

compinit -d ${XDG_DATA_HOME}/zsh/zcompdump-$ZSH_VERSION
