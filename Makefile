all: programs/test.bin programs/test.dump

%.bin: %.o
	riscv64-unknown-elf-objcopy -O binary $*.o $*.bin

%.dump: %.o
	riscv64-unknown-elf-objdump -d $*.o > $*.dump

%.o: %.s
	clang --target=riscv32 -march=rv32i $*.s -c -o $*.o

clean:
	rm -f **/*.o **/*.bin **/*.dump
