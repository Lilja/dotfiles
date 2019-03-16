import os
import sys
from functools import partial

from install.colors import print_title
from install.fileutil import concat_path_and_normalize

if sys.version_info < (3, 4):
    print('Python 2 is not supported for the install script')
    exit(1)

from install import argparser
from pathlib import Path
from install.utils import symlink_file, copy_file, write_local_git_config, read_local_git_config, \
    present_git_config, ask, is_mac, check_if_already_configured
from install.xdg import XDG, load_xdg_defaults
from install.argparser import usage

SOURCE_DIR = os.getcwd()
INSTALL_TARGET = str(Path.home())

load_xdg_defaults()

xdg = XDG(INSTALL_TARGET)


def install_xdg_config_home(force=False):
    files = [
        'zsh',
        'vim',
        'git'
    ]
    for file in files:
        symlink_file(
            os.path.join(SOURCE_DIR, file),
            os.path.join(xdg.config, file)
        )


def install_bash(force=False):
    print_title('Bash')
    if not ask('Do you want install bash configs?'):
        return
    paths = [
        ('bash/bashrc', '.bashrc'),
        ('bash/bash_profile', '.bash_profile'),
    ]
    for s, t in paths:
        copy_file(
            concat_path_and_normalize(SOURCE_DIR, s),
            concat_path_and_normalize(INSTALL_TARGET, t)
        )


def install_git(force=False):
    print_title('Git')
    local_git_config = concat_path_and_normalize(xdg.config, 'git/config.local')
    installed = False
    if os.path.exists(local_git_config):
        installed = True
        email, user_name = read_local_git_config(local_git_config)
        present_git_config(email, user_name)

    prefix = 're' if installed else ''
    if force or ask(f'Do you want to {prefix}configure git?'):
        full_name = input('What\'s your full name?')
        email = input('What\'s your e-mail address?')

        write_local_git_config(local_git_config, full_name, email)


def install_vscode():
    print_title('Visual Studio Code Settings')
    if not is_mac():
        prefix = '~/.config'
    else:
        prefix = '~/Library/Application\ Support'

    if check_if_already_configured(concat_path_and_normalize(prefix, 'Code/User/settings.json')):
        return

    if not ask('Install Visual Studio Code Settings'):
        return

    symlink_file(
        concat_path_and_normalize(SOURCE_DIR, 'vscode/settings.json'),
        concat_path_and_normalize(prefix, 'Code/User/settings.json'),
    )


execution = {
    'install_dot_files': install_xdg_config_home,
    'install_bash': install_bash,
    'git': install_git,
    'vscode': install_vscode,
}

_usage = partial(usage, execution)


def execute_all_steps():
    for step in execution.values():
        step()


def main(command: str):
    if command == 'all':
        execute_all_steps()
    elif command in execution.keys():
        execution[command](True)
    else:
        print(_usage(command))


if __name__ == '__main__':
    main(**vars(argparser.get_arg_parser(execution)))
