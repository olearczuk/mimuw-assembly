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

extern void manipulate_color(PPMBYTE*, int, int, uint8_t, int8_t);

void generate_filename(char *new_filename, char *filename) {
    char *copied1 = strdup(filename);
    char *dir_name = dirname(copied1);

    char *copied2 = strdup(filename);
    char *base_name = basename(copied2);

    sprintf(new_filename, "%s/Y%s", dir_name, base_name);
}

int main(int argc, char **argv) {
    if (argc != 4) {
        fprintf(stderr, "Wrong number of program arguments\n");
        exit(1);
    }

    char *filename = argv[1];
    PPM image;
    easyppm_read(&image, filename);

    int8_t value = (int8_t)atoi(argv[3]);
    char color = argv[2][0];

    if (color == 'R')
        manipulate_color(image.image, image.width, image.height, 1, value);
    else if (color == 'G')
        manipulate_color(image.image, image.width, image.height, 2, value);
    else if (color == 'B')
        manipulate_color(image.image, image.width, image.height, 3, value);
    else {
        fprintf(stderr, "Wrong color name\n");
        exit(1);
    }

    char *new_filename = (char*) malloc((strlen(filename) + 1) * sizeof(char));

    generate_filename(new_filename, filename);

    easyppm_write(&image, new_filename);

    free(new_filename);
    return 0;
}
