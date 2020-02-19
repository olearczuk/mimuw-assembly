#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

struct cell {
    float cur_temp, new_temp;
    bool is_heater;
} typedef cell;

extern void start(int width, int height, void* cells, float cooler_temp, float weight);
extern void place(int heaters_number, int* x, int* y, float* temps);
extern void step();

int width, height;

void print_matrix(cell *cells) {
    for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++)
            printf("%.2f | ", cells[i * width + j].cur_temp);
        printf("\n");
    }
    printf("\n");
}

void run_program(FILE* f, float weight, int steps) {
    float cooler_temp;
    fscanf(f, "%d %d %f", &width, &height, &cooler_temp);

    int cells_number = width * height;
    cell* cells = malloc(sizeof(cell) * cells_number);

    for (int i = 0; i < cells_number; i++) {
        float temp;
        fscanf(f, "%f", &temp);
        cells[i].cur_temp = temp;
        cells[i].new_temp = temp;
        cells[i].is_heater = false;
    }

    start(width, height, (void*) cells, cooler_temp, weight);

    int heaters_number;
    fscanf(f, "%d", &heaters_number);

    int* x = malloc(sizeof(int) * heaters_number);
    int* y = malloc(sizeof(int) * heaters_number);
    float *temps = malloc(sizeof(float) * heaters_number);

    for (int i = 0; i < heaters_number; i++)
        fscanf(f, "%d %d %f", &x[i], &y[i], &temps[i]);

    place(heaters_number, x, y, temps);

    free(x);
    free(y);
    free(temps);

    print_matrix(cells);
    for (int i = 0; i < steps; i++) {
        while(getchar() != '\n') {}
        step();
        print_matrix(cells);
    }
    free(cells);
}

int main(int argc, char **argv) {
    if (argc != 4) {
        fprintf(stderr, "Wrong number of program arguments\n");
        exit(1);
    }

    char *file = argv[1];
    float weight = strtof(argv[2], NULL);
    int steps = atoi(argv[3]);

    FILE *f = fopen(file, "r");
    if (!f) {
        fprintf(stderr, "Could not open file '%s'\n", file);
        exit(1);
    }

    run_program(f, weight, steps);

    return 0;
}