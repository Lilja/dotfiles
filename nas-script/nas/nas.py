import os

if os.environ['DEBUG']:
    print('Loading packages')

import yaml
import socket
from functools import wraps
import time
from yaspin import yaspin
import os
from stat import S_ISDIR
from datetime import datetime
from os.path import join
from pathlib import Path
from tabulate import tabulate
from contextlib import contextmanager
import argparse
import paramiko
import logging
import sshtunnel

if os.environ['DEBUG']:
    print('Done packages')


logging.basicConfig()
logger = logging.getLogger(__name__)

bastion_host_url = "jump.dersand.net"
bastion_host_port = 7302
bastion_host_username = "jump"

nas_url = "solo.lan"
nas_port = 2222

locally_bound_ip = '127.0.0.1'
locally_bound_port = 10022
time_obj = {}


def measure(func):
    @wraps(func)
    def _time_it(*args, **kwargs):
        start = int(round(time.time() * 1000))
        try:
            return func(*args, **kwargs)
        finally:
            end_ = int(round(time.time() * 1000)) - start
            time_obj[func.__name__] = f"{end_ if end_ > 0 else 0} ms"
    return _time_it


@measure
@contextmanager
def bastion_host():
    with sshtunnel.open_tunnel(
        (bastion_host_url, bastion_host_port),
        ssh_username="jump",
        remote_bind_address=(nas_url, nas_port),
        local_bind_address=(locally_bound_ip, locally_bound_port)
    ) as tunnel:
        logger.info('Opening tunnel')
        yield tunnel



def connect_to_target(target, user, local_network=False):
    try:
        target.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        logger.info(f'Connecting to nas with user {user!r}')
        if local_network:
            target.connect(nas_url, port=nas_port, username=user)
        else:
            target.connect(locally_bound_ip, port=locally_bound_port, username=user)
    except paramiko.ssh_exception.PasswordRequiredException:
        error('Username not valid')


def client_is_on_local_network():
    try:
        socket.gethostbyname(nas_url)
        return True
    except socket.gaierror:
        return False


@measure
@contextmanager
def sftp_client(user):
    if client_is_on_local_network():
        logger.info('Connecting to local network')
        with paramiko.SSHClient() as target:
            connect_to_target(target, user, local_network=True)
            yield target.open_sftp()
    else:
        logger.info('Connecting via proxy network')
        with bastion_host() as _:
            with paramiko.SSHClient() as target:
                connect_to_target(target, user)
                yield target.open_sftp()


@measure
def get_filesize(nbytes):
    suffixes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB']
    i = 0
    while nbytes >= 1024 and i < len(suffixes)-1:
        nbytes /= 1024.
        i += 1
    f = ('%.2f' % nbytes).rstrip('0').rstrip('.')
    return '%s %s' % (f, suffixes[i])


def error(msg):
    print(msg)
    exit(1)


@measure
def list_files(source_dir, user, long_format):
    logger.info('list files / list folder')
    with sftp_client(user) as client:
        try:
            print(source_dir)
            client.chdir(source_dir)
            if long_format:
                files = client.listdir()
                files = [
                    (f, client.stat(join(source_dir, f)))
                    for f in files
                ]
                files = [
                    (file, get_filesize(stat_cmd.st_size), datetime.fromtimestamp(stat_cmd.st_mtime).strftime('%Y-%m-%d %H:%M:%S'))
                    for (file, stat_cmd) in files
                ]
                output = tabulate(files)
            else:
                output = " ".join(client.listdir())

            print(output)
        except FileNotFoundError:
            print('Directory does not exist')


@measure
def sftp_walk(client,remotepath):
    # Kindof a stripped down  version of os.walk, implemented for 
    # sftp.  Tried running it flat without the yields, but it really
    # chokes on big directories.
    path=remotepath
    files=[]
    folders=[]
    for f in client.listdir_attr(remotepath):
        if S_ISDIR(f.st_mode):
            folders.append(f.filename)
        else:
            files.append(f.filename)
    yield path,folders,files
    for folder in folders:
        new_path=os.path.join(remotepath,folder)
        for x in sftp_walk(client, new_path):
            yield x


@measure
def mkdir_p(client, remote_directory):
    if remote_directory == '/':
        # absolute path so change directory to root
        client.chdir('/')
        return
    if remote_directory == '':
        # top-level relative directory must exist
        return
    try:
        client.chdir(remote_directory) # sub-directory exists
    except IOError:
        dirname, basename = os.path.split(remote_directory.rstrip('/'))
        mkdir_p(client, dirname) # make parent directories
        client.mkdir(basename) # sub-directory missing, so created it
        client.chdir(basename)
        return True

def create_nested_directory(client, localpath, remotepath):
    head, tail = os.path.split(localpath)
    logger.info(f"head: {head!r} tail {tail!r}")
    if not tail:
        logger.info('Extra directory needed')
        last_path_part = os.path.basename(os.path.normpath(localpath))
        _remotepath = os.path.join(remotepath, last_path_part)
        logger.info(f'New directory {_remotepath}')
        mkdir_p(client, _remotepath)
        return _remotepath
    else:
        logger.info('Extra directory not needed')
        return remotepath

@measure
def _put_all(client, localpath, remotepath, initial=False):
    ''' Uploads the contents of the source directory to the target path. The
        target directory needs to exists. All subdirectories in source are
        created under target.
    '''
    if not folder_exists(client, remotepath, remote=True):
        mkdir_p(client, remotepath)
    logger.info(f'{remotepath} {localpath}')
    logger.info(f'localpath: {localpath!r}')
    if initial:
        logger.info(f'remotepath, extra directory might be needed')
        remotepath = create_nested_directory(client, localpath, remotepath)
    # exit(1)
    for item in os.listdir(localpath):
        if os.path.isfile(os.path.join(localpath, item)):
            item_to_upload = os.path.join(localpath, item)
            path_to_upload = os.path.join(remotepath, item)
            yield (
                item_to_upload,
                path_to_upload,
                os.stat(item_to_upload).st_size
            )
        else:
            sub_dir_folder_name = os.path.join(remotepath, item)
            mkdir_p(sub_dir_folder_name)
            _put_all(os.path.join(localpath, item), sub_dir_folder_name)


@measure
def _get_all(client,remotepath,localpath):
    client.chdir(os.path.split(remotepath)[0])
    parent=os.path.split(remotepath)[1]
    try:
        os.mkdir(localpath)
    except:
        pass
    for walker in sftp_walk(client, parent):
        try:
            os.mkdir(os.path.join(localpath,walker[0]))
        except:
            pass
        for file in walker[2]:
            file_source = os.path.join(walker[0],file)
            file_target = os.path.join(localpath,walker[0],file)
            file_size = client.stat(file_source).st_size
            yield (file_source, file_target, file_size)


@measure
def perform_io(client, remotepath, localpath, mode, action):
    spinner = yaspin()
    spinner.start()
    spinner.text='Calculating files in tree'
    total_bytes = 0
    time_start = time.time()
    files_to_perform_io = []
    if mode == "get":
        files_to_perform_io = list(_get_all(client, remotepath, localpath))
    else:
        files_to_perform_io = list(_put_all(client, remotepath, localpath, initial=True))

    files = len(files_to_perform_io)
    download_size = get_filesize(sum(size for (_, _, size) in files_to_perform_io))
    spinner.text = (f'{remotepath} contains {files} files of {download_size}')
    for (file_source, file_target, file_size) in files_to_perform_io:
        total_bytes = total_bytes + file_size
        action(spinner, file_source, file_target, file_size)
    diff = time.time() - time_start
    spinner.stop()

    neat_time = time.strftime("%H:%M:%S", time.gmtime(diff))
    verb = "Download" if mode == "get" else "Upload"
    plural = "s" if files == 1 else ""
    print(f'{verb} of {files} file{plural} {get_filesize(total_bytes)} took {neat_time}')


@measure
def download_or_upload_folder(mode, client, remotepath, localpath):
    if mode == "get":
        verb = "Downloading"
    else:
        verb = "Uploading"

    def action(spinner, file_source, file_target, file_size):
        text = f"{verb} {file_source} {get_filesize(file_size)}"
        spinner.text = text
        def byte_count(xfer, to_be_xfer):
            spinner.text = (text + " transferred: {0:.0f} %".format((xfer / to_be_xfer) * 100))
        if mode == "get":
            logger.info(f'Getting {file_source} -> {file_target}')
            client.get(file_source, file_target, callback=byte_count)
        else:
            logger.info(f'Putting {file_source} -> {file_target}')
            client.put(file_source, file_target, callback=byte_count)

    perform_io(client, remotepath, localpath, mode, action)



@measure
def file_exists(client, path, remote=True):
    if remote:
        try:
            client.stat(path)
            return True
        except IOError:
            return False
    else:
        return os.path.exists(path)


@measure
def folder_exists(client, path, remote=True):
    if remote:
        try:
            client.chdir(path)
            return True
        except (IOError, paramiko.sftp.SFTPError):
            return False
    else:
        return os.path.exists(path)


@measure
def is_folder(client, path, remote=True):
    if remote:
        try:
            client.chdir(path)
            return True
        except (IOError, paramiko.sftp.SFTPError):
            return False
    else:
        os.path.isdir(path)


@measure
def rm(client, path):
    files = client.listdir(path)

    logger.info(f'Removing files {files}')
    for f in files:
        filepath = os.path.join(path, f)
        try:
            if folder_exists(client, filepath, remote=True):
                raise OSError()
            logger.info(f'Attempting to remove {filepath}')
            w = client.remove(filepath)
            logger.info(f'Removing file: {filepath} good! {w}')
        except (OSError, IOError):
            logger.info(f'Recursively removing inside {filepath}')
            rm(client, filepath)

    if folder_exists(client, path, remote=True):
        logger.info(f'Rmdir {path}')
        client.rmdir(path)


@measure
def figure_out_if_download_or_upload(file_exists_locally, file_exists_remotely):
    if file_exists_locally and not file_exists_remotely:
        return 'put'
    if file_exists_remotely and not file_exists_locally:
        return 'get'


@measure
def is_folder_empty(client, destination, remote=False):
    if remote:
        return len(client.listdir(destination)) == 0
    else:
        return len(os.listdir(destination)) == 0


@measure
def check_if_destination_exists_or_to_overwrite(client, destination, source_is_folder, overwrite, remote_destination=False):
    if source_is_folder:
        if folder_exists(client, destination, remote=remote_destination) and not is_folder_empty(client, destination, remote=remote_destination) and not overwrite:
            error('Destination folder already exists. Either change directory or pass the --overwrite flag to overwrite this dir')
    else:
        if file_exists(client, destination, remote=remote_destination) and not overwrite:
            error('Destination file already exists. Either change filename or pass the --overwrite flag to overwrite this dir')


@measure
def get_the_file(client, source_dir, destination, overwrite):
    source_is_folder = folder_exists(client, source_dir, remote=True)
    check_if_destination_exists_or_to_overwrite(client, destination, source_is_folder, overwrite, remote_destination=False)

    if source_is_folder:
        logger.info('Downloading recursively a folder')
        download_or_upload_folder('get', client, source_dir, destination)
    else:
        logger.info('Downloading a file')
        client.get(source_dir, destination)


@measure
def put_the_file(client, source_dir, destination, overwrite):
    source_is_folder = is_folder(client, source_dir, remote=False)
    check_if_destination_exists_or_to_overwrite(client, destination, source_is_folder, overwrite, remote_destination=True)

    if source_is_folder:
        logger.info('Uploading recursively a folder')
        download_or_upload_folder('put', client, source_dir, destination)
    else:
        logger.info('Uploading a file')
        client.put(source_dir, destination)


@measure
def copy_files(source_dir, destination, user, overwrite=False):
    logger.info('copy files / copy folder')
    with sftp_client(user) as client:
        file_exists_remotely = file_exists(client, source_dir, remote=True)
        file_exists_locally = file_exists(client, source_dir, remote=False)
        logger.info(f'File exists locally? {file_exists_locally}. File exists remotely? {file_exists_remotely}')
        if not file_exists_locally and not file_exists_remotely:
            error('Neither file/directory exists on remote/local system. Check your paths.')

        get_or_put = figure_out_if_download_or_upload(file_exists_locally, file_exists_remotely)
        logger.info(f'We should {get_or_put} the file')
        if get_or_put == "get":
            get_the_file(client, source_dir, destination, overwrite=overwrite)
        elif get_or_put == "put":
            put_the_file(client, source_dir, destination, overwrite=overwrite)


@measure
def rm_files(source_dir, recursive, user):
    logger.info('Rm files / rm folder')
    with sftp_client(user) as client:
        file_exists_remotely = file_exists(client, source_dir, remote=True)
        if not file_exists_remotely:
            error('File/directory does not exist')

        if not recursive:
            folder_exist = folder_exists(client, source_dir, remote=True)
            if folder_exist:
                client.rmdir(source_dir)
            else:
                client.remove(source_dir)
        else:
            rm(client, source_dir)


@measure
def rmdir_files(source_dir, user):
    logger.info('Rmdir folder')
    with sftp_client(user) as client:
        file_exists_remotely = file_exists(client, source_dir, remote=True)
        if not file_exists_remotely:
            error('File/directory does not exist')

        if client.listdir(source_dir):
            error('Directory not empty')
        client.rmdir(source_dir)


def cp_parser(subparsers):
    cp = subparsers.add_parser('cp')

    cp.add_argument('source')
    cp.add_argument('destination')
    # cp.add_argument('--user')
    cp.add_argument('--overwrite', default=False, action="store_true")


def ls_parser(subparsers):
    cp = subparsers.add_parser('ls')
    cp.add_argument('source', default="/")
    cp.add_argument('-l', action='store_true')
    # cp.add_argument('--user')


def rm_parser(subparsers):
    cp = subparsers.add_parser('rm')
    cp.add_argument('source', default="/")
    cp.add_argument('-r', action='store_true')
    # cp.add_argument('--user')


def rmdir_parser(subparsers):
    cp = subparsers.add_parser('rmdir')
    cp.add_argument('source', default="/")
    # cp.add_argument('--user')


def read_config_file():
    config_file = os.path.join(
        str(Path.home()), '.config', 'nas-script', 'config'
    )
    if os.path.exists(config_file):
        with open(config_file, 'r') as c:
            try:
                return yaml.safe_load(c)
            except yaml.YAMLError as exc:
                return {}
    return {}

def get_input(config):
    parser = argparse.ArgumentParser(description='Nas script')
    parser.add_argument('--benchmark', action="store_true", default=False)
    parser.add_argument('-v', action="store_true", default=False)
    if config.get('user'):
        logger.info(f'Falling back to --user with {config.get("user")}')
        parser.add_argument('--user', default=config.get('user'))
    else:
        parser.add_argument('--user', required=True)

    subparsers = parser.add_subparsers(dest='subparser_name')

    cp_parser(subparsers)
    ls_parser(subparsers)
    rm_parser(subparsers)
    rmdir_parser(subparsers)
    return parser.parse_args()


def main():
    config = read_config_file()
    prog_input = get_input(config)
    if prog_input.v:
        logger.setLevel(logging.INFO)

    if prog_input.subparser_name == 'ls':
        list_files(prog_input.source, prog_input.user, prog_input.l)
    if prog_input.subparser_name == 'cp':
        copy_files(prog_input.source, prog_input.destination, prog_input.user, prog_input.overwrite)
    if prog_input.subparser_name == 'rm':
        rm_files(prog_input.source, prog_input.r, prog_input.user)
    if prog_input.subparser_name == 'rmdir':
        rmdir_files(prog_input.source, prog_input.user)

    if prog_input.benchmark:
        print(time_obj)
    return 0


if __name__ == "__main__":
    main()
