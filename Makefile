CC_DATA_DIR = src/computercraft/loader/data

PROGRAMS = $(patsubst programs/%.s,%,$(wildcard programs/*.s))

all: $(PROGRAMS)

$(PROGRAMS): %: $(CC_DATA_DIR)/%.bin programs/%.dump

$(CC_DATA_DIR)/%.bin: programs/%.bin
	mkdir -p $(CC_DATA_DIR)
	cp programs/$*.bin $(CC_DATA_DIR)/$*.bin

%.bin: %.out
	riscv64-unknown-elf-objcopy --output-target binary $*.out $*.bin

%.dump: %.out
	riscv64-unknown-elf-objdump --disassemble $*.out > $*.dump

%.out: %.o memory.ld
	riscv64-unknown-elf-ld -melf32lriscv --script=memory.ld -o $*.out $*.o

%.o: %.s
	clang --target=riscv32 -march=rv32i --compile -o $*.o $*.s

.PHONY: clean
clean:
	rm -f \
		programs/*.o \
		programs/*.out \
		programs/*.bin \
		programs/*.dump \
		$(CC_DATA_DIR)/*.bin
