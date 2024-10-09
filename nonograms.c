/**
 * nonograms.c
 *
 * A program to play nonogram puzzles.
 *
 * Prior to translating this program into MIPS assembly, you may wish to make use
 * of the provided `nonograms.simple.c` file. In it, you can replace complex C
 * constructs like loops with constructs which will be easier to translate
 * into assembly. To help you check that you haven't altered the behaviour of
 * the game, you can run some automated tests using the command
 *     1521 autotest nonograms.simple
 * The simplified C version of this code is not marked.
 */

#include <stdio.h>
#include <stdlib.h>

/////////////////// Constants ///////////////////

#define TRUE 1
#define FALSE 0

#define MAX_WIDTH 12
#define MAX_HEIGHT 10

#define UNMARKED 1
#define MARKED 2
#define CROSSED_OUT 3

///////////////////// Types /////////////////////

struct clue_set {
    int vertical_clues[MAX_WIDTH][MAX_HEIGHT];
    int horizontal_clues[MAX_HEIGHT][MAX_WIDTH];
};

//////////////////// Globals ////////////////////

int width, height;
char selected[MAX_HEIGHT][MAX_WIDTH];
char solution[MAX_HEIGHT][MAX_WIDTH];

struct clue_set selection_clues;
struct clue_set solution_clues;
struct clue_set *displayed_clues;

////////////////// Prototypes ///////////////////

// Subset 1
int  main(void);
void prompt_for_dimension(char *name, int min, int max, int *pointer);
void initialise_game(void);
void game_loop(void);

// Subset 2
int  decode_coordinate(char input, char base, int maximum, int previous);
void read_solution(void);
char lookup_clue(int clues[], int offset, int horizontal);
void compute_all_clues(char grid[MAX_HEIGHT][MAX_WIDTH], struct clue_set *clues);

// Subset 3
void make_move(void);
void print_game(char grid[MAX_HEIGHT][MAX_WIDTH]);
void compute_clue(int index, int is_vertical, char grid[MAX_HEIGHT][MAX_WIDTH], int *clue);
int  is_game_over(void);

// Provided functions. You might find it useful
// to look at their implementation.
void dump_game_state(void);
void get_command(void);


/////////////////// Subset 1 ////////////////////

// Our main function, sets up the game and then starts the game loop
int main(void) {
    // Hints for these two function calls:
    //  - Use `la` to get the address of the two strings
    //  - Use `la` for the address of height and width
    prompt_for_dimension("height", 3, MAX_HEIGHT, &height);
    prompt_for_dimension("width", 3, MAX_WIDTH, &width);

    initialise_game();
    read_solution();
    putchar('\n');

    game_loop();

    printf("Congrats, you won!\n");
}

// Asks for the user for the game width/height, then writes the value to *pointer
void prompt_for_dimension(char *name, int min, int max, int *pointer) {
    int input;

    while (TRUE) {
        // Prompt the user
        printf("Enter the %s: ", name);
        scanf("%d", &input);

        // Check the width/height is not too small or too big
        if (input < min) {
            printf("error: too small, the minimum %s is %d\n", name, min);
        } else if (input > max) {
            printf("error: too big, the maximum %s is %d\n", name, max);
        } else {
            break;
        }
    }

    // Hint: this *stores* the *word* `input` at address `pointer`
    *pointer = input;
}

// Initialise both `selected` and `solution` to be all UNMARKED
void initialise_game(void) {
    for (int row = 0; row < height; row++) {
        for (int col = 0; col < width; col++) {
            selected[row][col] = UNMARKED;
            solution[row][col] = UNMARKED;
        }
    }
}

// The game loop: repatedly prints the game, allows the user to make a move,
// and then recomputes the game state
void game_loop(void) {
    while (!is_game_over()) {
        print_game(selected);
        get_command();
        compute_all_clues(selected, &selection_clues);
    }

    // Final print of the game to show the winning state
    print_game(selected);
}

/////////////////// Subset 2 ////////////////////

// This is used later in make_move, it converts letter inputs into
// numbers. Returns `previous` if the input is out of range.
int decode_coordinate(char input, char base, int maximum, int previous) {
    if (input >= base && input < base + maximum) {
        return input - base;
    } else {
        return previous;
    }
}

// Reads the coordinates of the solution to determine what the clues should be
void read_solution(void) {
    printf("Enter solution: ");

    int total = 0;

    int row, col;
    while (TRUE) {
        scanf("%d", &row);
        scanf("%d", &col);

        if (row < 0 || col < 0) {
            break;
        }

        solution[row % height][col % width] = MARKED;
        total++;
    }

    compute_all_clues(solution, &solution_clues);
    displayed_clues = &solution_clues;

    // Print out the total number of coordinates we read in
    printf("Loaded %d solution coordinates\n", total);
}

// This is used later for print_game, it looks up one of the clues in the
// array, with some extra arithmetic to add spacing between horizontal clues
char lookup_clue(int clues[], int offset, int horizontal) {
    int index = offset / (horizontal + 1);

    if ((horizontal && offset % 2 == 1) || clues[index] == 0) {
        return ' ';
    }

    return '0' + clues[index];
}

// Recomputes all the clues by making the appropriate calls to compute_clue, for
// each row and column
void compute_all_clues(char grid[MAX_HEIGHT][MAX_WIDTH], struct clue_set *clues) {
    for (int col = 0; col < width; col++) {
        compute_clue(col, TRUE, grid, clues->vertical_clues[col]);
    }

    for (int row = 0; row < height; row++) {
        compute_clue(row, FALSE, grid, clues->horizontal_clues[row]);
    }
}

/////////////////// Subset 3 ////////////////////

// Prompt for, and then execute, a move
void make_move(void) {

    char first_letter, second_letter;

    printf("Enter first coord: ");
    scanf(" %c", &first_letter);
    printf("Enter second coord: ");
    scanf(" %c", &second_letter);

    int row = -1;
    int col = -1;

    // We allow for both row then col (aB) and col then row (Ba) by trying
    // to extract the row/col from both letters
    col = decode_coordinate(first_letter, 'A', width, col);
    col = decode_coordinate(second_letter, 'A', width, col);
    row = decode_coordinate(first_letter, 'a', height, row);
    row = decode_coordinate(second_letter, 'a', height, row);

    // decode_coordinate will leave the row/col unchanged if the coordinate
    // is invalid, so if either was invalid they will stay at -1
    if (row == -1 || col == -1) {
        printf("Bad input, try again!\n");
        make_move();
        return;
    }

    // Ask the user what they want to do to the cell
    char new_cell_value = 0;
    do {
        printf("Enter choice (# to select, x to cross out, . to deselect): ");

        char choice;
        scanf(" %c", &choice);

        if (choice == '#') {
            new_cell_value = MARKED;
        } else if (choice == 'x') {
            new_cell_value = CROSSED_OUT;
        } else if (choice == '.') {
            new_cell_value = UNMARKED;
        } else {
            printf("Bad input, try again!\n");
        }
    } while (!new_cell_value);

    selected[row][col] = new_cell_value;
}

void print_game(char grid[MAX_HEIGHT][MAX_WIDTH]) {
    if (displayed_clues == &selection_clues) {
        printf("[printing counts for current selection rather than solution clues]\n");
    }

    // The `gutter' is the space above and to the left of the grid where we show the clues.
    int vertical_gutter = (height + 1) / 2;
    int horizontal_gutter = width + 1;

    // Print the vertical gutter
    for (int gutter_row = 0; gutter_row < vertical_gutter; gutter_row++) {
        // Print the space to the left of top clues
        for (int gutter_col = 0; gutter_col <= horizontal_gutter; gutter_col++) {
            putchar(' ');
        }

        // Print the top clues
        for (int col = 0; col < width; col++) {
            putchar(lookup_clue(
                displayed_clues->vertical_clues[col], gutter_row, 0
            ));
        }

        putchar('\n');
    }

    // Print the top coordinate reference (ABCDEF...)
    for (int col = 0; col < horizontal_gutter + width + 1; col++) {
        if (col <= horizontal_gutter) {
            putchar(' ');
        } else {
            putchar('A' + (col - horizontal_gutter - 1));
        }
    }
    putchar('\n');

    for (int row = 0; row < height; row++) {
        // Print this row's horizontal gutter
        for (int gutter_col = 0; gutter_col < horizontal_gutter; gutter_col++) {
            putchar(lookup_clue(
                displayed_clues->horizontal_clues[row], gutter_col, 1
            ));
        }

        // Print this row's coordinate reference letter
        putchar('a' + row);

        // Print the grid for this row
        for (int col = 0; col < width; col++) {
            int selected_cell = grid[row][col];

            if (selected_cell == UNMARKED) {
                putchar('.');
            } else if (selected_cell == CROSSED_OUT) {
                putchar('x');
            } else if (selected_cell == MARKED) {
                putchar('#');
            } else {
                putchar('?');
            }
        }

        putchar('\n');
    }
}

// Calculate a single row/column of a horizontal or vertical clue
void compute_clue(int index, int is_vertical, char grid[MAX_HEIGHT][MAX_WIDTH], int *clues) {
    int row, col, dx, dy, clue_length, clue_display_length;
    row = col = dx = dy = 0;

    if (is_vertical) {
        col = index;
        dy = 1;
        clue_length = MAX_HEIGHT;
        clue_display_length = (height + 1) / 2;
    } else {
        row = index;
        dx = 1;
        clue_length = MAX_WIDTH;
        clue_display_length = (width + 1) / 2;
    }

    int clue_index = 0;
    // run_length is the current length of consecutive MARKEDs
    int run_length = 0;

    while (row < height && col < width) {
        if (grid[row][col] == MARKED) {
            // One more cell in the run
            run_length++;
        } else if (run_length != 0) {
            // End of a run, add the length as a clue
            clues[clue_index++] = run_length;
            run_length = 0;
        }

        row += dy;
        col += dx;
    }

    if (run_length != 0) {
        // Add the clue for the final run
        clues[clue_index++] = run_length;
    }

    int leftovers = clue_display_length - clue_index;

    // Fill the rest of the clues with 0 (not displayed)
    for (int i = clue_index; i < clue_length; i++) {
        clues[i] = 0;
    }

    // And finally copy over the clues to the end of the array
    for (int i = clue_length - 1; i >= 0; i--) {
        if (i >= leftovers) {
            clues[i] = clues[i - leftovers];
        } else {
            clues[i] = 0;
        }
    }
}

// And finally one last function (a bit easier than the previous two!)
// so the game ends once the user solves the puzzle
int is_game_over(void) {
    for (int row = 0; row < MAX_HEIGHT; row++) {
        for (int col = 0; col < MAX_WIDTH; col++) {
            int selection_clue = selection_clues.vertical_clues[col][row];
            int solution_clue = solution_clues.vertical_clues[col][row];
            if (selection_clue != solution_clue) {
                return FALSE;
            }

            selection_clue = selection_clues.horizontal_clues[row][col];
            solution_clue = solution_clues.horizontal_clues[row][col];
            if (selection_clue != solution_clue) {
                return FALSE;
            }
        }
    }

    return TRUE;
}


/////////////////// Provided ////////////////////

// Read and then execute a command from the user
void get_command(void) {
    printf(" >> ");
    char command;
    scanf(" %c", &command);

    if (command == 'm') {
        make_move();
    } else if (command == 'q') {
        exit(0);
    } else if (command == 'd') {
        dump_game_state();
    } else if (command == 's') {
        displayed_clues = &selection_clues;
    } else if (command == 'S') {
        displayed_clues = &solution_clues;
    } else if (command == '?') {
        print_game(solution);
    } else {
        printf("Bad command\n");
    }
}

// For debugging purposes, output the game state
void dump_game_state(void) {
    printf("width = %d, height = %d\n", width, height);

    printf("selected:\n");
    for (int row = 0; row < height; row++) {
        for (int col = 0; col < width; col++) {
            printf("%d ", selected[row][col]);
        }
        putchar('\n');
    }

    printf("solution:\n");
    for (int row = 0; row < height; row++) {
        for (int col = 0; col < width; col++) {
            printf("%d ", solution[row][col]);
        }
        putchar('\n');
    }

    printf("displayed_clues vertical:\n");
    for (int row = 0; row < MAX_HEIGHT; row++) {
        for (int col = 0; col < MAX_WIDTH; col++) {
            printf("%d ", displayed_clues->vertical_clues[col][row]);
        }
        putchar('\n');
    }

    printf("displayed_clues horizontal:\n");
    for (int row = 0; row < MAX_HEIGHT; row++) {
        for (int col = 0; col < MAX_WIDTH; col++) {
            printf("%d ", displayed_clues->horizontal_clues[row][col]);
        }
        putchar('\n');
    }
}
