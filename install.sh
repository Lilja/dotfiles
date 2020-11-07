#!/bin/sh
executable="dotdrop"
executable="./../dotdrop/dotdrop.sh"

function install_win {
    export DOTDROP_TMPDIR=~/.cache/dotdrop && source dotbin/XDG.sh && "$executable" install --profile windows --cfg config.yaml
}

function install {
    export DOTDROP_TMPDIR=~/.cache/dotdrop && source dotbin/XDG.sh && "$executable" install --profile linux --cfg config.yaml
}

if [ "$1" ] && [ "$1" == "windows" ]; then
	install_win "$2"
else
	install "$2"
fi
