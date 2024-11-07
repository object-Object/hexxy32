import json
from pathlib import Path
import sys

MAX_CHUNK_SIZE = 512


def main():
    path = Path(sys.argv[1])
    data = path.read_bytes()
    output = [[]]
    for i in range(0, len(data), 4):
        word = data[i : i + 4]
        iota = int.from_bytes(word, byteorder="big")
        output[-1].append(iota)
        if len(output[-1]) >= MAX_CHUNK_SIZE:
            output.append([])
    output[-1] += [0] * (MAX_CHUNK_SIZE - len(output[-1]))
    print(json.dumps(output, separators=(",", ":")))


if __name__ == "__main__":
    main()
