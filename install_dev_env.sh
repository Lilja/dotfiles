#!/bin/sh

if [ -z "$XDG_CACHE_HOME" ]; then
				echo "No xdg cache"
				exit 1
fi

mkdir -p "$XDG_CACHE_HOME/neovim"
cd "$XDG_CACHE_HOME/neovim"
pyenv global 3.9.13
python3 -m venv neovim-py
neovim-py/bin/pip install pynvim



mkdir -p "$XDG_CACHE_HOME/neovim/neovim-js"
cd neovim-js
yarn init -y
yarn add typescript typescript-language-server @volar/vue-language-server neovim prettier

pip install cli-tools-info --upgrade

