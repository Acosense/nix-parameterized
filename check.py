import argparse
import json


def parse_args():
    parser = argparse.ArgumentParser(
        description="Compute given file with parameters."
    )
    parser.add_argument("src", help="JSON file with parameters")
    parser.add_argument("dst", help="JSON file with results")
    return parser.parse_args()

def func(a, b, c):
    return a + b + c


def main():
    args = parse_args()

    with open(args.src) as fin:
        parameters = json.load(fin)

    result = func(**parameters)
    with open(args.dst, "w") as fout:
        json.dump(parameters | {"result": result}, fout)

if __name__ == "__main__":
    main()
