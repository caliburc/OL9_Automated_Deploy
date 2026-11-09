#!/usr/bin/env python3
"""Roll a random number between 1 and a user-supplied maximum.

Usage:
    python3 roll.py          # rolls 1-500
    python3 roll.py 100      # rolls 1-100

Compatible with Python 3.6+.
"""
import argparse
import random
import sys

DEFAULT_MAX = 500


def positive_int(value):
    try:
        number = int(value)
    except ValueError:
        raise argparse.ArgumentTypeError("'{}' is not a whole number".format(value))
    if number < 1:
        raise argparse.ArgumentTypeError("number must be 1 or greater (got {})".format(number))
    return number


def main():
    parser = argparse.ArgumentParser(
        description="Roll a random number between 1 and MAX (default {}).".format(DEFAULT_MAX)
    )
    parser.add_argument(
        "max",
        nargs="?",
        type=positive_int,
        default=DEFAULT_MAX,
        help="highest number that can be rolled (default: {})".format(DEFAULT_MAX),
    )
    args = parser.parse_args()

    result = random.randint(1, args.max)
    print("Rolling 1-{}: {}".format(args.max, result))
    return 0


if __name__ == "__main__":
    sys.exit(main())
