import os
from pathlib import Path


def concat_path_and_normalize(*paths):
    home_free_paths = [
        _clean(a)
        for a in paths
    ]
    return os.path.normpath(os.path.join(*home_free_paths))


def _clean(x: str):
    variants = [
        '~/',
        '${HOME}',
        '$HOME'
    ]
    mutated = x
    for _a in variants:
        mutated = mutated.replace(_a, str(Path.home()) + '/')
    return mutated





