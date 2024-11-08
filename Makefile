CC_DATA_DIR = src/computercraft/loader/data

PROGRAMS = test load

all: $(PROGRAMS)

$(PROGRAMS): %: $(CC_DATA_DIR)/%.bin.json programs/%.bin programs/%.dump

$(CC_DATA_DIR)/%.bin.json: programs/%.bin.json
	mkdir -p $(CC_DATA_DIR)
	mv programs/$*.bin.json $(CC_DATA_DIR)/$*.bin.json

%.bin.json: %.bin
	python3 scripts/dump.py $*.bin > $*.bin.json

%.bin: %.o
	riscv64-unknown-elf-objcopy -O binary $*.o $*.bin

%.dump: %.o
	riscv64-unknown-elf-objdump -d $*.o > $*.dump

%.o: %.s
	clang --target=riscv32 -march=rv32i $*.s -c -o $*.o

.PHONY: clean
clean:
	rm -f programs/*.o programs/*.bin programs/*.bin.json programs/*.dump $(CC_DATA_DIR)/*.bin.json
