ASM_PROGRAMS = $(patsubst programs/%.s,%,$(wildcard programs/*.s))
RUST_PROGRAMS = $(filter-out hexxy32,$(patsubst rust/%,%,$(wildcard rust/*)))

.PHONY: all
all: asm rust

.PHONY: asm
asm: $(ASM_PROGRAMS)

.PHONY: rust
rust: $(RUST_PROGRAMS)

$(ASM_PROGRAMS): %: build/cc_data/%.bin build/%.dump

$(RUST_PROGRAMS): %: | build/cc_data/rust
	cd rust/$* && cargo robjcopy ../../build/cc_data/rust/$*.bin

# data dumps for the ComputerCraft-based memory loader
build/cc_data/%.bin: build/%.out | build/cc_data
	riscv64-unknown-elf-objcopy --output-target binary build/$*.out build/cc_data/$*.bin

build/%.dump: build/%.out
	riscv64-unknown-elf-objdump --disassemble build/$*.out > build/$*.dump

build/%.out: build/%.o
	riscv64-unknown-elf-ld -melf32lriscv --script=rust/hexxy32/link.x -o build/$*.out build/$*.o

build/%.o: programs/%.s | build
	clang --target=riscv32 -march=rv32i --compile -o build/$*.o programs/$*.s

build:
	mkdir -p build

build/cc_data:
	mkdir -p build/cc_data

build/cc_data/rust:
	mkdir -p build/cc_data/rust

.PHONY: clean
clean:
	rm -rf build
