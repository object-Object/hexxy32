#![no_std]
#![no_main]

use alloc::vec::Vec;
use hexxy32::prelude::*;

entry!(main);

fn main() -> ! {
    println!("{}", "hello rust!");

    let mut data = Vec::new();
    println!("allocated vec");
    for i in 0..10 {
        data.push(i);
    }
    println!("{data:?}");

    halt(0);
}
