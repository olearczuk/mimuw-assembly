all: main

main: main.c easyppm.c color_manipulator.o
	gcc -no-pie -o main main.c easyppm.c color_manipulator.o -lm

.SECONDARY:

%.o: %.asm
	nasm -f elf64 -F dwarf -g $<


%: %.o
	ld $< -o $@ -lc --dynamic-linker=/lib64/ld-linux-x86-64.so.2


clean:
	rm -f *.o main
