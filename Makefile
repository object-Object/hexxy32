all: programs/test.bin

%.bin: %.o
	riscv64-unknown-elf-objcopy -O binary $*.o $*.bin

%.o: %.asm
	clang --target=riscv32 -march=rv32i $*.asm -c -o $*.o

clean:
	rm -f **/*.o **/*.bin
