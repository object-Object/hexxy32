#![no_std]
#![no_main]
#![allow(dead_code)]

use core::arch::asm;

use bitfield_struct::bitfield;
use hexxy32::io::{read_io_port, write_io_port};
use hexxy32::prelude::*;

const PORT_TX: u32 = 0;
const PORT_RX: u32 = 1;

const LED_BUILTIN: u8 = 13;

const HIGH: u8 = 1;
const LOW: u8 = 0;

const INPUT: u8 = 0;
const OUTPUT: u8 = 1;
const INPUT_PULLUP: u8 = 2;

#[repr(u8)]
#[derive(Debug, PartialEq, Eq)]
enum GPIOCommand {
    DigitalRead,
    DigitalWrite,
    PinMode,
}

impl GPIOCommand {
    const fn from_bits(value: u8) -> Self {
        match value {
            0 => Self::DigitalRead,
            1 => Self::DigitalWrite,
            _ => Self::PinMode,
        }
    }

    const fn into_bits(self) -> u8 {
        self as _
    }
}

#[bitfield(u32)]
struct MsgGPIOC2S {
    #[bits(2)]
    command: GPIOCommand,
    #[bits(4)]
    pin: u8,
    #[bits(2)]
    arg: u8,

    #[bits(24)]
    __: u32,
}

entry!(main);

fn main() -> ! {
    unsafe {
        write_io_port(
            PORT_TX,
            MsgGPIOC2S::new()
                .with_command(GPIOCommand::PinMode)
                .with_pin(LED_BUILTIN)
                .with_arg(OUTPUT)
                .into(),
        );
        sleep();

        write_io_port(
            PORT_TX,
            MsgGPIOC2S::new()
                .with_command(GPIOCommand::PinMode)
                .with_pin(2)
                .with_arg(INPUT)
                .into(),
        );
        sleep();

        let mut old_value = 0;

        loop {
            write_io_port(
                PORT_TX,
                MsgGPIOC2S::new()
                    .with_command(GPIOCommand::DigitalRead)
                    .with_pin(2)
                    .into(),
            );
            sleep_n(2);

            let value = read_io_port(PORT_RX);
            if value != old_value {
                old_value = value;

                print_str(match value {
                    0 => "turning light off",
                    1 => "turning light on",
                    _ => unreachable!(),
                });

                write_io_port(
                    PORT_TX,
                    MsgGPIOC2S::new()
                        .with_command(GPIOCommand::DigitalWrite)
                        .with_pin(LED_BUILTIN)
                        .with_arg(value as u8)
                        .into(),
                );
                sleep_n(1);
            }
        }
    }

    // halt(0)
}
