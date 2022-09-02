
set -x XDG_CONFIG_HOME $HOME/.config
set -x XDG_CACHE_HOME $HOME/.cache
set -x XDG_DATA_HOME $HOME/.local/share
set -x VIM_PLUGIN_DIR 'vim/plugged'


if test (hostname) = "DESKTOP-7DQK874"
    # main pc wsl2 config
    alias neovim="~/nvim-linux64/bin/nvim"
    set -lx AWS_VAULT_BACKEND pass
    set -lx GPG_TTY ( tty )
end

function setup_alias
    set -gx EDITOR nvim
    set -gx SHELL /bin/bash
    # set -gx VIMINIT 'let $MYVIMRC="$XDG_CONFIG_HOME/vim/vimrc" | source $MYVIMRC'

    alias vim=$EDITOR
    alias n=$EDITOR
    alias vim=$EDITOR
    alias v="vim"

    alias vmi=$EDITOR
    alias viom=$EDITOR
    alias n=$EDITOR

    alias jvim="vim -u ~/.config/vim/journal.vimrc"

    alias dots="pushd ~/dotfiles"

    alias gti="git"
    alias ls-l="ls -l"
    alias l="ls -l"

    alias ":w"="echo You\'re in a terminal, dumbass."
    alias ":q"="echo You\'re in a terminal, dumbass."
    alias ":x"="echo You\'re in a terminal, dumbass."
    alias gcm="git cdb"
    alias gfp="git ffpull"

    # Wanna watch some star wars?
    alias starwars="telnet towel.blinkenlights.nl"

    alias el="exa --long --header --git"
    set -gx EXA_COLORS "ur=36:gr=36:tr=36"
    set -gx EXA_COLORS "$EXA_COLORS:da=36"

end
if status --is-interactive
    setup_alias
    if type -q zellij
        zellij setup --generate-auto-start fish | source
    end
end


set -gx PYTHONPATH "$answer/site-packages" $PYTHONPATH
set -gx GOPATH "$XDG_CACHE_HOME/go"
set -gx PYENV_ROOT $HOME/.pyenv
set -gx PIPENV_PYTHON "$PYENV_ROOT/shims/python"
set -gx PIPENV_VENV_IN_PROJECT "yes"
set -gx GITMOB_COAUTHORS_PATH "$XDG_CONFIG_HOME/git/.git-coauthors"

function setup_pyenv
    if test -d $PYENV_ROOT/bin
        set -gx PATH $PYENV_ROOT/bin $PATH
        set -gx PATH $PYENV_ROOT/shims/ $PATH
        pyenv init - --no-rehash | source
        pyenv init --path | source
        which python3 | read -l answer
    end
end
status --is-interactive; and setup_pyenv


set -gx PATH $HOME/dotfiles/bin $HOME/.poetry/bin $HOME/.cargo/bin /usr/local/go/bin $GOPATH/bin $PATH
set -gx PATH $HOME/.local/bin:$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin /opt/homebrew/bin $PATH

if type -q yarn
    set -gx PATH (yarn global bin) $PATH
end

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

set -x LC_ALL en_US.UTF-8


if test -z (pgrep ssh-agent | string collect)
    eval (ssh-agent -c)
    set -Ux SSH_AUTH_SOCK $SSH_AUTH_SOCK
    set -Ux SSH_AGENT_PID $SSH_AGENT_PID
end
