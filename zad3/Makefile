all: main

main: main.c easyppm.c ppm_to_pgm.o
	gcc -o main main.c easyppm.c ppm_to_pgm.o -lm

.SECONDARY:

%.o: %.s
	as -o ppm_to_pgm.o ppm_to_pgm.s

clean:
	rm -f *.o main
