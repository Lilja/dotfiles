#!/bin/sh
executable="dotdrop"
executable="./../dotdrop/dotdrop.sh"
executable="${HOME}/.local/bin/dotdrop"

install_win() {
    export DOTDROP_TMPDIR=~/.cache/dotdrop && . dotbin/XDG.sh && "$executable" install --profile windows --cfg config.yaml
}

install() {
    export DOTDROP_TMPDIR=~/.cache/dotdrop && . dotbin/XDG.sh && "$executable" install --profile nix --cfg config.yaml
}

if [ "$1" ] && [ "$1" == "windows" ]; then
	install_win "$2"
else
	install "$2"
fi
