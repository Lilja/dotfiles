
set -x XDG_CONFIG_HOME $HOME/.config
set -x XDG_CACHE_HOME $HOME/.cache
set -x XDG_DATA_HOME $HOME/.local/share
# Don't panic about the double slash!
# https://vi.stackexchange.com/questions/16037/vim-swap-file-best-practices#:~:text=Use%20%2F%2F%20at%20the%20end,t%20create%20it%20for%20you).
set -x NVIM_SWAP_DIR "$XDG_DATA_HOME/nvim/swap//"
set -x NVIM_UNDO_DIR "$XDG_DATA_HOME/nvim/undo//"
set -x DOTFILE_DIR "$HOME/dotfiles"
set -x REAL_HOSTNAME_PATH "$DOTFILE_DIR/real_hostname"
set -x CODE_WORKSPACE_DIR "$HOME/code"

# Set the tmux-sessionizer helper variables.
set -x TMUX_SESSIONIZER_TOP_LEVEL_DIRS "$HOME/dotfiles "
set -x TMUX_SESSIONIZER_CODE_DIRS "$HOME/code $HOME/open-source "


if test -f {$REAL_HOSTNAME_PATH}
  set -gx REAL_HOSTNAME (cat $REAL_HOSTNAME_PATH)
else
  set -gx REAL_HOSTNAME (hostname)
end
if test -d /home/linuxbrew/.linuxbrew/bin
  set -gx PATH /home/linuxbrew/.linuxbrew/bin $PATH
end

if test $REAL_HOSTNAME = "DESKTOP-7DQK874"
  # main pc wsl2 config
  # alias nvim="~/Downloads/nvim-linux64/bin/nvim"
  set -lx AWS_VAULT_BACKEND pass
  set -lx GPG_TTY ( tty )
  set -gx PATH $HOME/code/flutter/bin $PATH
  set -gx ANDROID_SDK_ROOT $HOME/code/android-sdk
  set -gx PATH $ANDROID_SDK_ROOT/cmdline-tools/latest/bin $PATH
  set -gx PATH $PYENV_ROOT/bin $PATH
  set -gx PATH /home/linuxbrew/.linuxbrew/bin $PATH
  set -gx FLYCTL_INSTALL "/home/lilja/.fly"
  set -gx PATH "$FLYCTL_INSTALL/bin" $PATH

end



if test "$REAL_HOSTNAME" = "Eriks-MBP"
  # Work mac 2022
  set -gx AWS_VAULT_PROMPT "ykman"
  set -gx DOCKER_DEFAULT_PLATFORM "linux/amd64"
  alias fucs="avb --browser_path /Applications/Firefox.app/Contents/MacOS/firefox login --profile customs-stage --container Stage"
  alias fucu="avb --browser_path /Applications/Firefox.app/Contents/MacOS/firefox login --profile customs-us --container Us"
  alias fuce="avb --browser_path /Applications/Firefox.app/Contents/MacOS/firefox login --profile customs-eu --container Eu"
  alias fuqw="avb --browser_path /Applications/Firefox.app/Contents/MacOS/firefox login --profile qwaya --container Qwaya"
  alias fuci="avb --browser_path /Applications/Firefox.app/Contents/MacOS/firefox login --profile customs-shared-infrastructure --container 'Customs Infrastructure'"
  alias fudipu="avb --browser_path /Applications/Firefox.app/Contents/MacOS/firefox login --profile data-in-us --container 'DIP US'"
  alias fudips="avb --browser_path /Applications/Firefox.app/Contents/MacOS/firefox login --profile data-in-stage --container 'DIP Stage'"
  alias fudipe="avb --browser_path /Applications/Firefox.app/Contents/MacOS/firefox login --profile data-in-eu --container 'DIP EU'"
  alias fupt="avb --browser_path /Applications/Firefox.app/Contents/MacOS/firefox login --profile plugin-tools --container 'Plugin Tools'"
  set -gx PATH /opt/homebrew/opt/openjdk/bin $PATH

  function _run_in_plugin_scripts
      set -lx PLUGIN_FOLDER_PATH "/Users/lilja/code/connector-plugins/plugins"
      set script $argv[1]
      set --erase argv[1]
      # set AWS_VAULT_ROLE $argv[1]
      # set --erase argv[1]
      fish -c "
        pushd '/Users/lilja/code/plugin-scripts'
        set -x PYTHONPATH .:src
        pipenv run python3 $script.py $argv;
        popd
      "
  end

  function dfs
      _run_in_plugin_scripts download_for_source $argv
  end
  function dfs_nexus
      _run_in_plugin_scripts src/dfs_nexus $argv
  end

  set --universal nvm_default_version lts/jod
end

function setup_alias
  set -gx EDITOR nvim
  set -gx SHELL /bin/fish
  set -gx BAT_THEME "Catppuccin Mocha"
  if test "$REAL_HOSTNAME" = "Eriks-MBP"
    set -gx SHELL /opt/homebrew/bin/fish
  end
  if test "$REAL_HOSTNAME" = "lilyflower"
    set -gx SHELL /home/linuxbrew/.linuxbrew/bin/fish
  end
  set -gx PANE_TTY (tty)
  # set -gx VIMINIT 'let $MYVIMRC="$XDG_CONFIG_HOME/vim/vimrc" | source $MYVIMRC'

  alias vim=$EDITOR
  alias vi=$EDITOR
  alias n=$EDITOR
  alias vim=$EDITOR
  alias v="vim"
  alias b="bat"
  alias ss="zellij-sessionizer"

  alias vmi=$EDITOR
  alias viom=$EDITOR
  alias n=$EDITOR

  alias jvim="vim -u ~/.config/vim/journal.vimrc"

  alias dots="pushd ~/dotfiles"
  alias ws="pushd $CODE_WORKSPACE_DIR"

  alias gti="git"
  alias ls-l="ls -l"

  alias ":w"="echo You\'re in a terminal, dumbass."
  alias ":q"="echo You\'re in a terminal, dumbass."
  alias ":x"="echo You\'re in a terminal, dumbass."
  alias gcm="git cdb"
  alias gfp="git ffpull"
  alias vimswap="pushd $NVIM_SWAP_DIR"

  # Wanna watch some star wars?
  alias starwars="telnet towel.blinkenlights.nl"
  # AwsVaultProfile
  alias awp='cat ~/.aws/config | rg \'\[profile (.*)\]\' -r \'$1\' | fzf | read -l profile; and commandline -r "aws-vault exec $profile -- "'

  alias el="eza --long --header --git"
  alias l="el"
  alias tms="tmux-sessionizer"
  alias pn="pnpm"
  alias tm="tmux new-session -s dotfiles -c ~/dotfiles"
  set -gx EZA_COLORS "ur=36:gr=36:tr=36"
  set -gx EZA_COLORS "$EXA_COLORS:da=36"

end

set -gx PYTHONPATH "$answer/site-packages" $PYTHONPATH
set -gx GOPATH "$XDG_CACHE_HOME/go"
set -gx PYENV_ROOT "$XDG_CACHE_HOME/pyenv"
set -gx PIPENV_PYTHON "$PYENV_ROOT/shims/python"
set -gx PIPENV_VENV_IN_PROJECT "yes"
set -gx GITMOB_COAUTHORS_PATH "$XDG_CONFIG_HOME/git/.git-coauthors"

function setup_pyenv
  if type -q pyenv
    set -gx PATH $PYENV_ROOT/bin $PATH
    set -gx PATH $PYENV_ROOT/shims/ $PATH
    pyenv init - --no-rehash | source
    pyenv init --path | source
    which python3 | read -l answer
  end
end


set -gx PATH $HOME/dotfiles/bin $HOME/.poetry/bin $HOME/.cargo/bin /usr/local/go/bin $GOPATH/bin /usr/local/bin $PATH
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

function aws_vault_role
  # Check if "AWS_VAULT" environmental variable is set.
  if test -n "$AWS_VAULT"
    echo -n " using "
    set_color -o purple
    echo -n "$AWS_VAULT"
    set_color normal
    # AWS_CREDENTIAL_EXPIRATION is in format "2022-01-01T00:00:00Z"
    # Calculate the expiration time and present it as minutes if it's less than 60 minutes, hours if it's less than 24 hours.
    if test -n "$AWS_CREDENTIAL_EXPIRATION"
      # -d is a GNU date option, so this won't work on MacOS.
      if test (uname) = "Linux"
        set -f expiration (date -d $AWS_CREDENTIAL_EXPIRATION +%s)
      else
        set -f expiration (date -j -f "%Y-%m-%dT%H:%M:%SZ" $AWS_CREDENTIAL_EXPIRATION +%s)
      end

      set -l now (date -u +%s)
      set -l diff (math $expiration - $now)
      if test $diff -lt 0
        echo -n " ("
        set_color -o red
        echo -n "expired!"
        set_color normal
        echo -n ")"
      else if test $diff -lt 3600
        set -l result (math $diff / 60)
        set -l pretty_diff (math round $result)
        echo -n " ("
        set_color -o purple
        echo -n $pretty_diff
        echo -n "m"
        set_color normal
        echo -n ")"
      else if test $diff -lt 86400
        set -l result (math $diff / 3600)
        # result is now a float, so we need to round it to the nearest integer.
        set -l pretty_diff (math round $result)
        echo -n " (expires in "
        set_color -o purple
        echo -n $pretty_diff
        echo -n "h"
        set_color normal
        echo -n ")"
      end
    end
  end
end

function pretty_job_count
  set -l cmd (jobs -p)
  if test $status -ne 1
    # Count the number of jobs. The first line is the header, so we skip it.
    set -l count (echo $cmd | wc -w | grep -o '[0-9]*')
    # We need to subtract one from the count, because the first line is the header.
    echo -n " "
    set_color -o red
    echo -n $count
    set_color normal
    # For convenience, set a global variable. If other programs or plugins wants to use this.
    set -gx SHELL_JOB_COUNT $count
  else
    # For convenience, set a global variable. If other programs or plugins wants to use this.
    set -gx SHELL_JOB_COUNT 0
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
  aws_vault_role
  pretty_job_count
  set_color -o white
  echo -n ' λ '
end

if test -e ~/.config/fish/funnel.fish
  source ~/.config/fish/funnel.fish
end

set -Ux LSCOLORS ExFxCxDxBxegedabagacad

set -x LC_ALL en_US.UTF-8

if status --is-interactive
  setup_alias
end

if test -z (pgrep ssh-agent | string collect)
  eval (ssh-agent -c)
  set -Ux SSH_AUTH_SOCK $SSH_AUTH_SOCK
  set -Ux SSH_AGENT_PID $SSH_AGENT_PID
end


# pnpm
set -gx PNPM_HOME "/Users/lilja/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

# Disable npm scripts for security
export npm_config_ignore_scripts=true
