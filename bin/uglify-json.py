#!/usr/bin/env python2
import sys
import simplejson


def main(arg):
    if len(arg) != 2:
        print("Please send a parameter with stringified json")
        exit(1)
    try:
        k = simplejson.loads(arg[1])
    except Exception as e:
        print("Not valid json, message: {}".format(e.message))
        exit(1)

    print(simplejson.dumps(k))


if __name__ == '__main__':
    main(sys.argv)


