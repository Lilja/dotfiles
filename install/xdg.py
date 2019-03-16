import os
from functools import partial
from typing import Dict

from .utils import failure


def load_xdg_defaults():
    for k, v in _xdg_defaults().items():
        os.environ[k] = v


def _xdg_defaults() -> Dict[str, str]:
    obj = {}
    with open('dotbin/XDG.sh') as o:
        for f in o.readlines():
            k, v = f.replace('export ', '').split('=')
            v.replace(os.linesep, '')
            obj[k] = v.replace('\n', '').replace(os.linesep, '').replace('"', '')
    return obj


def _defensively_get_environment_variable(_env: str) -> str:
    _var = os.environ.get(_env)
    if not _var:
        failure(f'{_env} not defined.')
    return _var


def _clean_path(install_target: str, x: str):
    return os.path.normpath(x).replace('${HOME}', install_target)


class XDG(object):
    def __init__(self, install_target: str):
        clean_path = partial(_clean_path, install_target)
        self.config = clean_path(_defensively_get_environment_variable('XDG_CONFIG_HOME'))
        self.cache = clean_path(_defensively_get_environment_variable('XDG_CACHE_HOME'))
