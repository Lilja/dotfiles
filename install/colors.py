# coding: utf8
_ok = '✔'
_cross = '✖'


class colors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


def debug_print(x):
    pass


def indent(msg, _indent=2):
    indt = ''.join([' '] * _indent)
    return f"{indt}{msg}"


def indent_print(msg, _indent=2):
    print(indent(msg, _indent))


def newline():
    print('')


def failure(_x):
    print(f'{colors.WARNING}{_cross}{_x}{colors.ENDC}')
    exit(1)


def failure_indent(main_message, extra_msg=''):
    print(indent(f'{colors.FAIL}{_cross}{colors.ENDC} {main_message}{colors.ENDC} {extra_msg}'))


def print_title(msg: str):
    print(f'\n{colors.OKGREEN}{colors.BOLD}{msg}{colors.ENDC}\n')


def print_sub_title(msg: str):
    print(f'\n{msg}\n')


def ok(msg):
    print(f'{colors.OKGREEN}{_ok}{msg}{colors.ENDC}')


def ok_indent(msg):
    print(indent(f'{colors.OKGREEN}{_ok}{colors.ENDC} {msg}{colors.ENDC}', 2))


def ask(msg) -> bool:
    try:
        k = input(indent(f'{colors.WARNING}{msg}{colors.ENDC} [y/n]? '))
        if k == 'y':
            return True
        return False
    except KeyboardInterrupt:
        return False
