use core::{arch::asm, fmt};

use crate::constants::Syscall;

#[macro_export]
macro_rules! println {
    () => {
        $crate::println!("")
    };
    ($arg:ident) => {{
        $crate::io::_print_str($arg);
    }};
    ($($arg:tt)*) => {{
        $crate::io::_print(format_args!($($arg)*));
    }};
}

/// Internal function.
pub fn _print(msg: fmt::Arguments) {
    // TODO: figure out how to handle arguments with placeholders
    _print_str(
        msg.as_str()
            .unwrap_or("printing strings with placeholders is currently unsupported"),
    );
}

/// Internal function.
pub fn _print_str(msg: &str) {
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
