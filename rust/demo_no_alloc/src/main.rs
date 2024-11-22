#![no_std]
#![no_main]

use hexxy32::prelude::*;

entry!(main);

fn main() -> ! {
    let mut buffer = itoa::Buffer::new();
    let mut a = 0;
    let mut b = 1;
    for _ in 0..32 {
        let c = a + b;
        print_str(buffer.format(c));
        a = b;
        b = c;
    }
    halt(0)
}
