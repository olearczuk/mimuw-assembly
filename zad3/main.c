/*
    Here I am using easyppm (https://github.com/fmenozzi/easyppm).
    It assumes that image is presented in text form.
*/

#include <stdio.h>
#include <stdint.h>
#include <libgen.h>
#include <string.h>
#include <stdlib.h>
#include "easyppm.h"

extern void generate_pgm(PPMBYTE* image, int size, int R, int G, int B);

void print_to_file(char *filename, PPM image) {
    FILE *fp = fopen(filename, "w");
    if (!fp) {
        fprintf(stderr, "Could not open file %s for writing\n", filename);
        exit(1);
    }
    fprintf(fp, "P2\n%d %d 255\n", image.width, image.height);
    int x, y;
    ppmcolor c;
    for (y = 0; y < image.height; y++) {
        for (x = 0; x < image.width; x++) {
            c = easyppm_get(&image, x, y);
            fprintf(fp, "%d ",c.r);
        }
        fprintf(fp, "\n");
    }
    fclose(fp);
}

char* generate_filename(char *filename) {
    char *new_filename = strdup(filename);
    new_filename[strlen(new_filename) - 2] = 'g';
    return new_filename;
}

int main(int argc, char **argv) {
    int r_multiplier = 77, g_multiplier = 151, b_multiplier = 28;
    if (argc != 2 && argc != 5) {
        fprintf(stderr, "Wrong number of program arguments\n");
        exit(1);
    }

    if (argc == 5) {
        r_multiplier = atoi(argv[2]);
        g_multiplier = atoi(argv[3]);
        b_multiplier = atoi(argv[4]);
    }

    if (r_multiplier + g_multiplier + b_multiplier != 256) {
        fprintf(stderr, "Sum of multipliers should be 256\n");
        exit(1);
    }

    char *filename = argv[1];
    PPM image;
    easyppm_read(&image, filename);

    generate_pgm(image.image, image.width * image.height, r_multiplier, 
        g_multiplier, b_multiplier);

    char* new_filename = generate_filename(filename);
    print_to_file(new_filename, image);
    return 0;
}
