//! Graphics module for the 64x48 ComputerCraft display.

use bitflags::bitflags;

use crate::{
    io::{read_io_port, write_io_port},
    sleep,
};

pub const DISPLAY_WIDTH: usize = 64;
pub const DISPLAY_HEIGHT: usize = 48;
pub const DISPLAY_SIZE: usize = DISPLAY_WIDTH * DISPLAY_HEIGHT;

bitflags! {
    #[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Hash)]
    pub struct RenderFlags: u32 {
        const Buffer = 1 << 0;
        const Palettes = 1 << 1;
    }
}

/// https://tweaked.cc/module/colors.html
#[repr(u8)]
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum Color {
    White,
    Orange,
    Magenta,
    LightBlue,
    Yellow,
    Lime,
    Pink,
    Gray,
    LightGray,
    Cyan,
    Purple,
    Blue,
    Brown,
    Green,
    Red,
    Black,
}

// TODO: set up peripherals singleton
pub struct Screen {
    buffer: &'static mut [u8; DISPLAY_SIZE],
    palettes: &'static mut [u8; 16 * 3],
    io_port: u32,
}

impl Screen {
    pub fn init() -> Self {
        extern "C" {
            static mut _screen_start: u32;
        }

        let addr = &raw mut _screen_start;

        unsafe {
            Self {
                buffer: &mut *(addr as *mut [u8; DISPLAY_SIZE]),
                palettes: &mut *(addr.add(DISPLAY_SIZE) as *mut [u8; 16 * 3]),
                io_port: 15,
            }
        }
    }

    pub fn buffer(&self) -> &[u8; DISPLAY_SIZE] {
        self.buffer
    }

    pub fn buffer_mut(&mut self) -> &mut [u8; DISPLAY_SIZE] {
        self.buffer
    }

    pub fn palettes(&self) -> &[u8; 16 * 3] {
        self.palettes
    }

    pub fn palettes_mut(&mut self) -> &mut [u8; 16 * 3] {
        self.palettes
    }

    pub fn set_pixel(&mut self, x: usize, y: usize, color: Color) {
        self.buffer[y * DISPLAY_WIDTH + x] = color as u8;
    }

    pub fn clear(&mut self, color: Color) {
        for i in 0..self.buffer.len() {
            self.buffer[i] = color as u8;
        }
    }

    pub fn render(&mut self, flags: RenderFlags) {
        while !self.can_render() {
            sleep();
        }
        unsafe {
            write_io_port(self.io_port, flags.bits());
        }
    }

    pub fn can_render(&self) -> bool {
        unsafe { read_io_port(self.io_port) == 0 }
    }
}
