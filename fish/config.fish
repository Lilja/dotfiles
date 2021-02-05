set -x EDITOR vim

set -x XDG_CONFIG_HOME $HOME/.config
set -x XDG_CACHE_HOME $HOME/.cache
set -x XDG_DATA_HOME $HOME/.local/share

set -x SHELL /bin/bash

set -x VIMINIT 'let $MYVIMRC="$XDG_CONFIG_HOME/vim/vimrc" | source $MYVIMRC'

alias vmi=$EDITOR
alias viom=$EDITOR

alias jvim="vim -u ~/.config/vim/journal.vimrc"

alias dots="pushd ~/dotfiles"

alias gti="git"
alias ls-l="ls -l"
alias l="ls -l"

alias ":w"="echo You\'re in a terminal, dumbass."
alias ":q"="echo You\'re in a terminal, dumbass."
alias ":x"="echo You\'re in a terminal, dumbass."
#
# Wanna watch some star wars?
alias starwars="telnet towel.blinkenlights.nl"

if type -q pyenv
    pyenv init - | source
    which python3 | read -l answer
    set -gx PYTHONPATH "$answer/site-packages" $PYTHONPATH
    set -gx PYENV_ROOT $HOME/.pyenv
    set -gx PIPENV_PYTHON "$PYENV_ROOT/shims/python"
end
set -gx PIPENV_VENV_IN_PROJECT "yes"

set -gx PATH $HOME/dotfiles/bin $HOME/.poetry/bin $HOME/.cargo/bin $PATH
set -gx PATH $HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin $PATH


function git_branch
   set branch (git branch ^/dev/null | grep \* | sed 's/* //') 
   if set -q branch[1]
    echo -n ' on '
    if test "$branch" = "master"
        set_color -o white
    else
        set_color -o magenta
    end
    echo -n $branch
    set_color normal
   end
end

function fish_prompt
    set_color -o green # -o = bold
    echo -n $USER
    set_color normal
    echo -n ' in '
    set_color -o cyan # -o = bold
    echo -n (prompt_pwd)
    set_color normal
    git_branch
    set_color -o white
    echo -n ' λ '
end

if test -e ~/.config/fish/funnel.fish
    source ~/.config/fish/funnel.fish
end

set -Ux LSCOLORS ExFxCxDxBxegedabagacad

# Gruvbox pretty please!
# theme_gruvbox dark
set -x LC_ALL en_US.UTF-8

set plugin_scripts_folder "/Users/Lilja/code/umbrella/plugin-scripts"
set -x PLUGIN_FOLDER_PATH "/Users/lilja/code/umbrella/custom-data/plugins"

function dfs
    pushd "$plugin_scripts_folder"
    pipenv run python3 download_for_source.py $argv;  popd
end


