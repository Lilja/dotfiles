import os
import shutil
from subprocess import CalledProcessError
from sys import platform as _platform

from install.colors import failure, debug_print, indent_print, colors, newline
from install.windows import copy_and_backup_locals
from install.fileutil import concat_path_and_normalize


def is_windows() -> bool:
    k = _platform
    return k == 'win32' or k == 'win64'


def is_mac() -> bool:
    return _platform == 'darwin'


def is_linux() -> bool:
    k = _platform
    return k == 'linux' or k == 'linux2'


def symlink_file(file_that_exists: str, file_to_point_at_first_argument: str):
    if not os.path.exists(file_that_exists):
        failure('File/dir to copy doesn\'t exist')

    if is_windows():
        return copy_and_backup_locals(file_that_exists, file_to_point_at_first_argument, '\.local$')
    if not os.path.exists(file_to_point_at_first_argument):
        return os.symlink(file_that_exists, file_to_point_at_first_argument)

def link_zsh(source_dir):
    if is_windows():
        target = concat_path_and_normalize(
            str(Path.home()),
            '.zshenv'
        )
        source = concat_path_and_normalize(
            source_dir,
            'zsh/zshenv'
        )
        shutil.copy(target, source)
    else:
        os.symlink(source, target)


def check_if_already_configured(file_to_point_at: str):
    return os.path.exists(file_to_point_at)


def copy_file(source: str, dest: str):
    debug_print(f'Copying {source} to {dest}')
    shutil.copy(source, dest)


def write_local_git_config(filep, full_name, email):
    content = f"""
[user]
        email = {email}
        name = {full_name}
"""
    with open(filep, 'w') as o:
        debug_print(f'Writing to {filep}')
        o.write(content)


def read_local_git_config(filep):
    email = ''
    user_name = ''
    with open(filep, 'r') as o:
        for line in o.readlines():
            if "=" in line:
                if 'email' in line:
                    email = line.split('=')[1].replace('\n', '').lstrip()
                elif 'name' in line:
                    user_name = line.split('=')[1].replace('\n', '').lstrip()

    return email, user_name


def present_git_config(email: str, user_name: str):
    indent_print('Current git config:')
    indent_print(f'Name {colors.BOLD}{colors.OKGREEN}{user_name}{colors.ENDC}')
    indent_print(f'Email {colors.BOLD}{colors.OKGREEN}{email}{colors.ENDC}')
    newline()


def read_ssh_keys():
    try:
        import subprocess
        out: bytes = subprocess.check_output(['bash', 'ssh-keys.sh'], shell=True, env={'PATH': os.getenv('PATH')},
                                             stderr=subprocess.DEVNULL)
        contents = out.decode('utf-8').split('\n')
        for c in contents:
            print(c)
    except CalledProcessError:
        indent_print('Couldn\' fetch SSH keys fingerprints because bash is not supported in subprocess')
