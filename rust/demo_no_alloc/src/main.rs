#![no_std]
#![no_main]

use hexxy32::prelude::*;

entry!(main);

fn main() -> ! {
    print_str("hello rust!");

    let mut buffer = itoa::Buffer::new();
    for i in 0..10 {
        print_str(buffer.format(i));
    }

    halt(0);
}
