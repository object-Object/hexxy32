#![no_std]
#![allow(clippy::empty_loop)]

pub extern crate alloc;

use core::{
    arch::{asm, global_asm},
    panic::PanicInfo,
};
use embedded_alloc::LlffHeap as Heap;

use constants::Syscall;

pub mod constants;
pub mod io;
pub mod prelude;

#[global_allocator]
static HEAP: Heap = Heap::empty();

// init global/stack/frame pointers
#[rustfmt::skip]
global_asm!("
.section .text.start
    la gp, __global_pointer$
    
    la t1, _stack_start
    andi sp, t1, -16
    add s0, sp, zero
");

#[no_mangle]
#[link_section = ".text.start"]
unsafe extern "C" fn _start() -> ! {
    extern "C" {
        static mut __sbss: u8;
        static mut __ebss: u8;
        static mut __sdata: u8;
        static mut __edata: u8;
        static __sidata: u8;
        static __sheap: u8;
        static _heap_size: u8;
    }

    /*
    // zero bss
    // TODO: this is really slow.
    let count = &raw const __ebss as usize - &raw const __sbss as usize;
    core::ptr::write_bytes(&raw mut __sbss, 0, count);
    */

    // copy static variables
    let count = &raw const __edata as usize - &raw const __sdata as usize;
    core::ptr::copy_nonoverlapping(&__sidata as *const u8, &raw mut __sdata, count);

    unsafe {
        let heap_bottom = &__sheap as *const u8 as usize;
        let heap_size = &_heap_size as *const u8 as usize;
        HEAP.init(heap_bottom, heap_size);
    }

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

struct CriticalSection;
critical_section::set_impl!(CriticalSection);

// hexxy32 is single-threaded and doesn't support interrupts
unsafe impl critical_section::Impl for CriticalSection {
    unsafe fn acquire() -> critical_section::RawRestoreState {}
    unsafe fn release(_restore_state: critical_section::RawRestoreState) {}
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
