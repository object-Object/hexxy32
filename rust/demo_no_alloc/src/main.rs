#![no_std]
#![no_main]
#![allow(dead_code)]

use hexxy32::graphics::cc::{Color, RenderFlags, Screen};
use hexxy32::prelude::*;

entry!(main);

fn main() -> ! {
    let mut screen = Screen::init();

    screen.clear(Color::Black);

    screen.set_pixel(0, 0, Color::Red);
    screen.set_pixel(63, 0, Color::Green);
    screen.set_pixel(0, 47, Color::Blue);
    screen.set_pixel(63, 47, Color::Yellow);

    screen.render(RenderFlags::Buffer);

    halt(0)
}
