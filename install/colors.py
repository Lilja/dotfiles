

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
    print(f'{colors.WARNING}{_x}{colors.ENDC}')
    exit(1)


def print_title(msg: str):
    print(f'\n{colors.OKGREEN}{msg}{colors.ENDC}\n')


def print_sub_title(msg: str):
    print(f'\n{msg}\n')


