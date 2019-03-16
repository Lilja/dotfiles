import argparse


def get_arg_parser(execution) -> argparse.Namespace:
    def _get_choices():
        return [s for s in execution.keys()] + ['all']

    parser = argparse.ArgumentParser(description='Install these dotfiles')

    parser.add_argument('command', default='all', type=str, choices=_get_choices(), nargs='?')

    args = parser.parse_args()

    return args


def usage(execution, command):
    supported_commands = ','.join(k for k in execution.keys())
    return f'\'{command}\' not understood. Following arguments are understood: {supported_commands}'

