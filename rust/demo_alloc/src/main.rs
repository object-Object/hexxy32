#![no_std]
#![no_main]
#![allow(clippy::empty_loop)]

use alloc::vec::Vec;
use hexxy32::prelude::*;
use hexxy32::register::{cycle, instret};

entry!(main);

fn main() -> ! {
    println!("{}", "hello rust!");

    let mut data = Vec::new();
    println!("allocated vec");
    for i in 0..10 {
        data.push(i);
    }
    println!("{data:?}");

    println!("cycle: {}\ninstret: {}", cycle::read(), instret::read());

    halt(0);
}
