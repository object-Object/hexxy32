use core::arch::asm;

use crate::constants::Syscall;

pub const DISPLAY_WIDTH: usize = 16;
pub const DISPLAY_HEIGHT: usize = 16;
pub const DISPLAY_SIZE: usize = DISPLAY_WIDTH * DISPLAY_HEIGHT;

#[repr(u8)]
#[derive(Clone, Copy)]
pub enum Color {
    DarkGray,
    LightGray,
    DarkRed,
    LightRed,
    Orange,
    Yellow,
    Green,
    Blue,
    Purple,
}

// 16*16=256, so this should never cross a page boundary
#[repr(C, align(256))]
pub struct ScreenBuffer(pub [Color; DISPLAY_SIZE]);

impl ScreenBuffer {
    pub fn new() -> Self {
        Self::with_color(Color::DarkGray)
    }

    pub fn with_color(color: Color) -> Self {
        Self([color; DISPLAY_SIZE])
    }

    pub fn set_pixel(&mut self, x: usize, y: usize, color: Color) {
        let index = get_screen_index(x, y);
        self.0[index] = color
    }

    pub fn refresh(&self) {
        unsafe {
            asm!(
                "ecall",
                in("a0") self.0.as_ptr(),
                in("a7") Syscall::RefreshDisplay as u32,
                options(nostack),
            );
        };
    }
}

impl Default for ScreenBuffer {
    fn default() -> Self {
        Self::new()
    }
}

pub fn get_screen_index(x: usize, y: usize) -> usize {
    y * DISPLAY_WIDTH + x
}
