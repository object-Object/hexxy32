PROGRAMS = $(patsubst programs/%.s,%,$(wildcard programs/*.s))

all: $(PROGRAMS)

$(PROGRAMS): %: build/cc_data/%.bin build/%.dump

# data dumps for the ComputerCraft-based memory loader
build/cc_data/%.bin: build/%.out | build/cc_data
	riscv64-unknown-elf-objcopy --output-target binary build/$*.out build/cc_data/$*.bin

build/%.dump: build/%.out
	riscv64-unknown-elf-objdump --disassemble build/$*.out > build/$*.dump

build/%.out: build/%.o
	riscv64-unknown-elf-ld -melf32lriscv --script=memory.ld -o build/$*.out build/$*.o

build/%.o: programs/%.s | build
	clang --target=riscv32 -march=rv32i --compile -o build/$*.o programs/$*.s

build:
	mkdir -p build

build/cc_data:
	mkdir -p build/cc_data

.PHONY: clean
clean:
	rm -rf build
