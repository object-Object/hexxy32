# hexxy32

A RISC-V (`rv32i`) computer implemented in Hex Casting. Heavily WIP.

![](https://i.imgur.com/0LUewBC.png)

## Data representation

Memory is represented as a list of number iota. Hex Casting's numbers are internally stored as doubles (though some operations convert them to longs or ints), so we store 32 bits (4 bytes) in each number iota, as non-negative numbers between 0 and 2^32-1. This means immediates are unsigned by default and [converted to signed](https://ocroquette.wordpress.com/2015/10/26/converting-unsigned-to-signed-integers-using-powershell-or-excel/) only when necessary.

## Registers

Registers are stored in the [ravenmind](https://hexcasting.hexxy.media/v/0.10.3/1.0.dev22/en_us/#patterns/readwrite@hexcasting:local) as a list.

| Index | Value |
| ----- | ----- |
| 0-31  | Normal registers |
| 32    | Current `pc` |
| 33    | Next `pc` |

## Requirements

* Hex Casting 0.10.3
* Hexal
* Hex Gloop

## Links

* [Instructions lookup table](https://docs.google.com/spreadsheets/d/1i21hN2jmQvABMubGRTGIojoAtegI30-cbB2LlNZ8S3Y/edit?usp=sharing)
* [RISC-V spec](https://drive.google.com/file/d/1s0lZxUZaa7eV_O0_WsZzaurFLLww7ou5/view?usp=drive_link)
* [computerraria](https://github.com/misprit7/computerraria)
