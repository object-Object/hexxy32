# hexxy32

A RISC-V (`rv32i`) computer implemented in Hex Casting. Heavily WIP.

Backups of my development world can be downloaded from the [hexxy32-world](https://github.com/object-Object/hexxy32-world) repository.

https://github.com/user-attachments/assets/30436234-cfac-47f1-bec6-a259698d09bb

## Data representation

Memory is represented as a list of number iotas. Hex Casting's numbers are internally stored as doubles (though some operations convert them to longs or ints), so we store 32 bits (4 bytes) in each number iota, as non-negative numbers between 0 and 2^32-1. This means immediates are unsigned by default and [converted to/from signed](https://stackoverflow.com/a/62328202) only when necessary.

## Registers

Registers are stored in the [ravenmind](https://hexcasting.hexxy.media/v/0.11.1-7/1.0/en_us/#patterns/readwrite@hexcasting:local) as a list.

| Index | Value            |
| ----- | ---------------- |
| 0-31  | Normal registers |
| 32    | Current `pc`     |
| 33    | Next `pc`        |
| 34    | Trap message     |

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

| Index (a7) | Description        | a0        | a1     | a2  | a3  | a4  | a5  | a6  |
| ---------- | ------------------ | --------- | ------ | --- | --- | --- | --- | --- |
| 0          | Halt               | Exit code |        |     |     |     |     |     |
| 1          | Print ASCII string | Address   | Length |     |     |     |     |     |

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

## Implementation notes

### Misaligned loads/stores

Misaligned loads and stores are currently not supported, and will raise a fatal exception if attempted.

## Requirements

- Hex Casting 0.11.x
- Hexal
- MoreIotas
- HexDebug

## Links

- [Instructions lookup table](https://docs.google.com/spreadsheets/d/1i21hN2jmQvABMubGRTGIojoAtegI30-cbB2LlNZ8S3Y/edit?usp=sharing)
- [RISC-V spec](https://drive.google.com/file/d/1s0lZxUZaa7eV_O0_WsZzaurFLLww7ou5/view?usp=drive_link)
- [computerraria](https://github.com/misprit7/computerraria)
- [Aly's multiplication implementation](https://discord.com/channels/936370934292549712/986383249456644166/1199843847572836452)
