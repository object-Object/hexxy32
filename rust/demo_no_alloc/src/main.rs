#![no_std]
#![no_main]

use hexxy32::graphics::{Color, ScreenBuffer, DISPLAY_HEIGHT, DISPLAY_WIDTH};
use hexxy32::prelude::*;

entry!(main);

fn main() -> ! {
    let mut buffer = ScreenBuffer::new();

    buffer.set_pixel(0, 0, Color::LightRed);
    buffer.set_pixel(DISPLAY_WIDTH - 1, 0, Color::Green);
    buffer.set_pixel(0, DISPLAY_HEIGHT - 1, Color::Blue);
    buffer.set_pixel(DISPLAY_WIDTH - 1, DISPLAY_HEIGHT - 1, Color::Yellow);

    buffer.refresh();
    halt(0)
}
