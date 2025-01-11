use core::arch::asm;

#[cfg(feature = "alloc")]
use alloc::string::ToString;

use crate::constants::Syscall;

#[cfg(feature = "alloc")]
#[macro_export]
macro_rules! println {
    () => {
        $crate::io::print_str!("")
    };
    ($arg:ident) => {{
        $crate::io::print_str($arg);
    }};
    ($($arg:tt)*) => {{
        $crate::io::_print(format_args!($($arg)*));
    }};
}

/// Internal function.
#[cfg(feature = "alloc")]
pub fn _print(msg: core::fmt::Arguments) {
    print_str(msg.to_string().as_str());
}

pub fn print_str(msg: &str) {
    unsafe {
        asm!(
            "ecall",
            in("a0") msg.as_ptr(),
            in("a1") msg.len(),
            in("a7") Syscall::Print as u32,
            options(nostack),
        );
    };
}

#[allow(clippy::missing_safety_doc)]
pub unsafe fn read_io_port(port: u32) -> u32 {
    let mut value: u32 = port;
    asm!(
        "ecall",
        inout("a0") value,
        in("a7") Syscall::ReadIOPort as u32,
        options(nostack, nomem),
    );
    value
}

#[allow(clippy::missing_safety_doc)]
pub unsafe fn write_io_port(port: u32, value: u32) {
    asm!(
        "ecall",
        in("a0") port,
        in("a1") value,
        in("a7") Syscall::WriteIOPort as u32,
        options(nostack, nomem),
    );
}
