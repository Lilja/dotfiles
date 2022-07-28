if [ -z "$XDG_CACHE_HOME" ]; then
    export XDG_CACHE_HOME="${HOME}/.cache"
fi
if [ -z "$XDG_CONFIG_HOME" ]; then
    export XDG_CONFIG_HOME="${HOME}/.config"
fi
if [ -z "$XDG_DATA_HOME" ]; then
    export XDG_DATA_HOME="${HOME}/.local/share"
fi

if [ ! -d "$XDG_CACHE_HOME" ]; then
    mkdir -p "$XDG_CACHE_HOME"
fi
if [ ! -d "$XDG_CONFIG_HOME" ]; then
    mkdir -p "$XDG_CONFIG_HOME"
fi
if [ ! -d "$XDG_DATA_HOME" ]; then
    mkdir -p "$XDG_DATA_HOME"
fi
