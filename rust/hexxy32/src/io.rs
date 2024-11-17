use core::{arch::asm, fmt};

use alloc::string::ToString;

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
    _print_str(msg.to_string().as_str());
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
