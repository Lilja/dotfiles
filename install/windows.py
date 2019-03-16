# Windows compatibility
import os
import pathlib
import re
import shutil
import ntpath
import tempfile

from install.fileutil import concat_path_and_normalize
from install.utils import debug_print


def copy_and_backup_locals(file_that_exists, file_to_point_at_first_argument, matching):
    files_to_backup = backup_all_files_matching(file_to_point_at_first_argument, matching)
    tmp_dir = None
    if files_to_backup:
        tmp_dir = tempfile.TemporaryDirectory()
        for file in files_to_backup:
            backup_target = concat_path_and_normalize(tmp_dir.name, ntpath.basename(file))
            debug_print(f'Backing up {file} to {backup_target}')
            shutil.copy(file, backup_target)
    _remove_original(file_to_point_at_first_argument)

    _copy_files(file_that_exists, file_to_point_at_first_argument)

    if tmp_dir:
        files_to_restore_from_backup = zip(
            os.listdir(tmp_dir.name),
            files_to_backup,
        )

        for (backuped, target) in files_to_restore_from_backup:
            backup_parent_folder = tmp_dir.name
            absolute_backuped_file = concat_path_and_normalize(backup_parent_folder, backuped)
            debug_print(f'Restoring {absolute_backuped_file} from backup, to: {target}')
            dirname_of_target = os.path.dirname(target)
            if not os.path.exists(dirname_of_target):
                debug_print('Creating directories for copy')
                os.makedirs(dirname_of_target)
            shutil.copy(absolute_backuped_file, target)


def backup_all_files_matching(dir: str, matching: str):
    all_files = pathlib.Path(dir)
    files = list((f.name for f in all_files.glob('**/*')))
    return [
        concat_path_and_normalize(dir, f)
        for f in files
        if re.search(matching, f)
    ]


def _remove_original(x: str):
    if os.path.exists(x):
        debug_print(f'Removing {x} because it already exist')
        return shutil.rmtree(x)


def _copy_files(file_that_exists: str, file_to_point_at_first_argument: str):
    debug_print(f'Copying {file_that_exists} to {file_to_point_at_first_argument}')
    if os.path.isfile(file_that_exists):
        dirname_of_target = os.path.dirname(file_to_point_at_first_argument)
        if not os.path.exists(dirname_of_target):
            debug_print(f'Creating directories for copy, {dirname_of_target}')
            os.makedirs(dirname_of_target)
    if os.path.isfile(file_that_exists):
        return shutil.copy(file_that_exists, file_to_point_at_first_argument)
    return shutil.copytree(file_that_exists, file_to_point_at_first_argument)

