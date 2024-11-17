#![no_std]
#![no_main]

use hexxy32::{entry, halt, println};

entry!(main);

fn main() -> ! {
    println!("hello rust!");
    halt(0);
}
