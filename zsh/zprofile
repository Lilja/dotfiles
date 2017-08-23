export LSCOLORS=ExFxCxDxBxegedabagacad
if [ -z "$SSH_AUTH_SOCK" ]; then
    ssh-add -l &>/dev/null
    if [ "$?" = 2 ]; then
      test -r ~/.ssh-agent && \
        eval "$(<~/.ssh-agent)" >/dev/null

    fi
fi
