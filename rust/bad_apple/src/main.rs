#![no_std]
#![no_main]

use hexxy32::graphics::hex::{refresh_display, Color, ScreenBuffer};
use hexxy32::prelude::*;
use include_bytes_aligned::include_bytes_aligned;

static DATA: &[u8] = include_bytes_aligned!(256, "../assets/bad_apple.bin");

entry!(main);

fn main() -> ! {
    // add some delay (scuffed.)
    let interval = 30;
    for i in 0..(interval * 3) {
        if i % interval == 0 {
            let n = 3 - (i / interval);
            let color = match n {
                3 => Color::LightRed,
                2 => Color::Orange,
                1 => Color::Green,
                0 => Color::LightGray,
                _ => continue,
            };
            ScreenBuffer::with_color(color).refresh();
        }
    }

    // play video
    for i in (0..DATA.len()).step_by(256) {
        unsafe {
            refresh_display(DATA.as_ptr().add(i));
        }
    }

    ScreenBuffer::with_color(Color::LightGray).refresh();

    halt(0)
}
