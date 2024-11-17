#![no_std]
#![allow(clippy::empty_loop)]

use core::{
    arch::{asm, global_asm},
    panic::PanicInfo,
};

use constants::Syscall;

pub mod constants;
pub mod io;

// reset handling

// init stack pointer
#[rustfmt::skip]
global_asm!("
.section .text.start
    la sp, _stack_start
");

#[no_mangle]
#[link_section = ".text.start"]
unsafe extern "C" fn _start() -> ! {
    /*
    // initialize RAM
    extern "C" {
        static mut _sbss: u8;
        static mut _ebss: u8;
        static mut _sdata: u8;
        static mut _edata: u8;
        static _sidata: u8;
    }

    // zero bss
    let count = &_ebss as *const u8 as usize - &_sbss as *const u8 as usize;
    ptr::write_bytes(&mut _sbss as *mut u8, 0, count);

    // copy static variables
    let count = &_edata as *const u8 as usize - &_sdata as *const u8 as usize;
    ptr::copy_nonoverlapping(&_sidata as *const u8, &mut _sdata as *mut u8, count);
    */

    extern "Rust" {
        fn main() -> !;
    }

    main()
}

#[panic_handler]
fn panic(info: &PanicInfo) -> ! {
    match (info.message().as_str(), info.location()) {
        (Some(message), Some(location)) => println!("thread panicked at '{message}', {location}"),
        (Some(message), None) => println!("thread panicked at '{message}'"),
        (None, Some(location)) => println!("thread panicked at {location}"),
        (None, None) => println!("thread panicked"),
    }
    halt(1);
}

// macros

#[macro_export]
macro_rules! entry {
    ($path:path) => {
        #[export_name = "main"]
        pub unsafe fn __main() -> ! {
            // type check the given path
            let f: unsafe fn() -> ! = $path;
            f()
        }
    };
}

// functions

pub fn halt(code: u32) -> ! {
    unsafe {
        asm!(
            "ecall",
            in("a0") code,
            in("a7") Syscall::Halt as u32,
            options(nostack),
        );
    };
    loop {}
}
