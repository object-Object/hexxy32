PROGRAMS = test

all: $(PROGRAMS)

$(PROGRAMS): %: programs/%.bin.json programs/%.bin programs/%.dump
	mkdir -p src/computercraft/loader/data
	mv programs/$*.bin.json src/computercraft/loader/data/$*.bin.json

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
	rm -f **/*.o **/*.bin **/*.bin.json **/*.dump
