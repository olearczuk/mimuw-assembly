all: main

main: main.c heat_distribution.o
	gcc -no-pie -g -o main main.c heat_distribution.o

.SECONDARY:

%.o: %.asm
	nasm -f elf64 -F dwarf -g $<


%: %.o
	ld $< -o $@ -lc --dynamic-linker=/lib64/ld-linux-x86-64.so.2


clean:
	rm -f *.o main