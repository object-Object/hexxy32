# adapted from https://github.com/misprit7/computerraria/blob/f0ef4a74db/app/video/build.py

import cv2
from tqdm import trange

VIDEO_PATH = "./assets/bad_apple.mp4"
OUTPUT_PATH = "./assets/bad_apple.bin"

WIDTH, HEIGHT = 16, 16
COLOR = 5  # yellow


def main():
    video = cv2.VideoCapture(VIDEO_PATH)

    frame_count = int(video.get(cv2.CAP_PROP_FRAME_COUNT))
    print(f"Frames: {frame_count}")

    with open(OUTPUT_PATH, "wb") as f:
        for i in trange(frame_count):
            success, frame = video.read()

            if not success:
                break

            if i % 2 == 0:
                continue

            frame = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

            _, frame = cv2.threshold(
                src=frame,
                thresh=128,
                maxval=255,
                type=cv2.THRESH_BINARY,
            )

            frame = cv2.resize(
                src=frame,
                dsize=(WIDTH, HEIGHT),
                interpolation=cv2.INTER_NEAREST,
            )

            frame = frame.flatten() // 255
            frame = frame * COLOR

            f.write(frame.tobytes())


if __name__ == "__main__":
    main()
