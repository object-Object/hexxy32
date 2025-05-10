# hexxy32

A RISC-V (`RV32I_Zicntr_Zicsr`) computer implemented in Hex Casting.

Backups of my development world can be downloaded from the [hexxy32-world](https://github.com/object-Object/hexxy32-world) repository.

https://youtube.com/watch?v=AMMsWnvkJDo

## Data representation

Memory is represented as a list of number iotas. Hex Casting's numbers are internally stored as doubles (though some operations convert them to longs or ints), so we store 32 bits (4 bytes) in each number iota, as non-negative numbers between 0 and 2^32-1. This means immediates are unsigned by default and [converted to/from signed](https://stackoverflow.com/a/62328202) only when necessary.

## Registers

Registers are stored in the [ravenmind](https://hexcasting.hexxy.media/v/0.11.1-7/1.0/en_us/#patterns/readwrite@hexcasting:local) as a list.

| Index | Value                                             |
| ----- | ------------------------------------------------- |
| 0-31  | Normal registers                                  |
| 32    | Current `pc`                                      |
| 33    | Next `pc`                                         |
| 34    | Trap message                                      |
| 35    | Exit flag (0=continue, 1=halt, 2=go to next tick) |

## Traps

Instructions and interrupts can trigger trap handlers (ie. raise exceptions) by setting index 34 of the ravenmind to specific values. The format is as follows:

| Handler index | Trap type | Description     | Value                                    |
| ------------- | --------- | --------------- | ---------------------------------------- |
| N/A           | N/A       | Default value   | `0`                                      |
| 0             | Invisible | Memory load     | `[0, register, address, # bits, signed]` |
| 1             | Invisible | Memory store    | `[1, value, address, # bits]`            |
| 2             | Requested | System call     | `[2, value, address, # bits]`            |
| 3             | Fatal     | Fatal exception | `[3, ...error message lines]`            |

## System calls

| Index (a7) | Description        | a0        | a1     | a2  | a3  | a4  | a5  | a6  | Return (a0) |
| ---------- | ------------------ | --------- | ------ | --- | --- | --- | --- | --- | ----------- |
| 0          | Halt               | Exit code |        |     |     |     |     |     |             |
| 1          | Print ASCII String | Address   | Length |     |     |     |     |     |             |
| 2          | Refresh Display    | Address   |        |     |     |     |     |     |             |
| 3          | Read I/O Port      | Port      |        |     |     |     |     |     | Value       |
| 4          | Write I/O Port     | Port      | Value  |     |     |     |     |     |             |

## Physical layout

### Processor

Positions are relative to the block where the processor is executed (ie. where the wisp is summoned, or where the player is looking when the debug trinket is used).

| Y offset | Value                                             |
| -------- | ------------------------------------------------- |
| +5       | trap handlers (see previous table)                |
| +4       | decoders (see spreadsheet)                        |
| +3       | instructions 20-38, null-padded (see spreadsheet) |
| +2       | instructions 0-19 (see spreadsheet)               |
| +1       | [startup, shutdown, eval, bootstrap]              |
| 0        | N/A                                               |
| -1       | ravenmind state                                   |

### Memory

Main memory is represented as a 19x19x19 cube of focus holders (from HexDebug), each containing a list of 512 number iotas. A greater sentinel is spawned at the center of the cube.

## Display

A simple 16x16 display is implemented using focal ports from Ducky Peripherals. Pixels in the screen buffer can be set by writing to a buffer somewhere in memory, where the first byte is the top left pixel, the second is one pixel to the right, etc. The display is refreshed using the Refresh Display syscall, where the address points to the screen buffer. The address **must** be word-aligned, and the buffer **must not** cross a page boundary. The easiest way to do this should be to align the buffer to 256 bytes.

### Colors

| Iota type | Hex code | Color      | Value |
| --------- | -------- | ---------- | ----- |
| Garbage   | 505050   | dark gray  | 0     |
| Null      | aaaaaa   | light gray | 1     |
| Jump      | cc0000   | dark red   | 2     |
| Vector    | ff3030   | light red  | 3     |
| Pattern   | ffaa00   | orange     | 4     |
| Boolean   | ffff55   | yellow     | 5     |
| Double    | 55ff55   | green      | 6     |
| Entity    | 55ffff   | blue       | 7     |
| List      | aa00aa   | purple     | 8     |

## Implementation notes

### Misaligned loads/stores

Misaligned loads and stores are currently not supported, and will raise a fatal exception if attempted.

### CSRs

CSR instructions that write to the CSR are currently not implemented, and will raise a fatal exception if attempted, since all existing CSRs are read-only.

To simplify the implementation, hexxy32 deviates from the RISC-V spec by incrementing the `instret` counter when ECALL is executed (`instret` is not supposed to be incremented for instructions that cause synchronous exceptions).

The `cycleh` and `instreth` counters are not implemented, since I'm not expecting hexxy32 to run for the amount of time it would take to overflow those counters.

The `cycle` and `instret` counters are cleared during processor bootstrap. This means they will always be zero when stepping with the trinket launcher. I think this should be fine, since these counters are meant for performance monitoring, which would not be necessary when stepping the processor by hand.

## Requirements

- Hex Casting 0.11.x
- Hexal
- MoreIotas
- HexDebug
- Chisels and Bits

## Links

- [Instructions lookup table](https://docs.google.com/spreadsheets/d/1i21hN2jmQvABMubGRTGIojoAtegI30-cbB2LlNZ8S3Y/edit?usp=sharing)
- [RISC-V spec](https://drive.google.com/file/d/1s0lZxUZaa7eV_O0_WsZzaurFLLww7ou5/view?usp=drive_link)
- [computerraria](https://github.com/misprit7/computerraria)
- [Aly's multiplication implementation](https://discord.com/channels/936370934292549712/986383249456644166/1199843847572836452)
