
set -x XDG_CONFIG_HOME $HOME/.config
set -x XDG_CACHE_HOME $HOME/.cache
set -x XDG_DATA_HOME $HOME/.local/share
set -x VIM_PLUGIN_DIR 'vim/plugged'

function setup_alias
    set -xg EDITOR vim
    set -xg SHELL /bin/bash
    set -xg VIMINIT 'let $MYVIMRC="$XDG_CONFIG_HOME/vim/vimrc" | source $MYVIMRC'

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
    alias gcm="git checkout master"
    alias gfp="git ffpull"

    # Wanna watch some star wars?
    alias starwars="telnet towel.blinkenlights.nl"
end
status --is-interactive; and setup_alias


set -gx PYTHONPATH "$answer/site-packages" $PYTHONPATH
set -gx PYENV_ROOT $HOME/.pyenv
set -gx PIPENV_PYTHON "$PYENV_ROOT/shims/python"
set -gx PIPENV_VENV_IN_PROJECT "yes"

function setup_pyenv
    if type -q pyenv
        pyenv init - --no-rehash | source
        which python3 | read -l answer
    end
end
status --is-interactive; and setup_pyenv


set -gx PATH $HOME/dotfiles/bin $HOME/.poetry/bin $HOME/.cargo/bin $PATH
set -gx PATH $HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin $PATH

function _git_branch_name
  echo (command git symbolic-ref HEAD 2> /dev/null | sed -e 's|^refs/heads/||')
end

function _git_is_dirty
  echo (command git status -s --ignore-submodules=dirty 2> /dev/null)
end

function git_branch
    if [ (_git_branch_name) ]
        set -l branch (_git_branch_name)
        echo -n ' on '
        if [ (_git_is_dirty) ]
            set_color -o yellow
        else
            set_color -o green
        end
        echo -n $branch
        set_color normal
    else
        set -l git_dir (git rev-parse --git-dir 2> /dev/null)
        if test $status -eq 0
            if test -f {$git_dir}/rebase-merge/head-name
                set_color -o yellow
                echo -n " rebasing "
                set -l branch (cat (git rev-parse --git-dir)/rebase-merge/head-name | sed 's#refs/heads/##g')
                echo -n $branch
                set_color normal
            else
                set_color -o yellow
                echo -n " detached HEAD"
                set_color normal
            end
        end
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

set -gx SHELL (command -s fish)

function decrypt_custom_source
    pushd ~/code/umbrella/customs-scripts && aws-vault exec qwaya -- pipenv run python src/decrypt-password.py $argv;
    popd
end
