from pathlib import Path
import sys


def main():
    path = Path(sys.argv[1])
    data = path.read_bytes()
    output = []
    for i in range(0, len(data), 4):
        word = data[i:i+4]
        iota = int.from_bytes(word, byteorder="big")
        output.append(str(iota))
    print(",".join(output))


if __name__ == "__main__":
    main()
