/**
 * nonograms.c
 *
 * A program to play nonogram puzzles.
 *
 * Prior to translating this program into MIPS assembly, you may wish
 * to simplify the contents of this file. You can replace complex C
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

struct clue_set selection_clues, solution_clues;
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


/////////////////// Subset 0 ////////////////////

// Our main function, setups up the game and then starts the game loop
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

    prompt_again:
    // Prompt the user
    printf("Enter the %s: ", name);
    scanf("%d", &input);

    // Check the width/height
    if (input < min) {
        printf("error: too small, the minimum %s is %d\n", name, min);
        goto prompt_again;
    }

    if (input > max) {
        printf("error: too big, the maximum %s is %d\n", name, max);
        goto prompt_again;
    }

    // Store the input at the pointer address
    *pointer = input;
}


// Initialise both `selected` and `solution` to be all UNMARKED
void initialise_game(void) {
    int row = 0, col = 0;

    initialise_loop:
    if (row >= height) return; // Exit if all rows are initialized

    solution[row][col] = UNMARKED; // Initialize the solution grid
    selected[row][col] = UNMARKED; // Initialize the selected grid

    col++;
    if (col < width) {
        goto initialise_loop; // Continue initializing columns in the current row
    }

    row++;
    col = 0; // Reset column for the next row
    goto initialise_loop; // Continue initializing rows
}


// The game loop: repatedly prints the game, allows the user to make a move,
// and then recomputes the game state
void game_loop(void) {
    game_loop_start:
    if (is_game_over()) goto game_loop_end; // Check if the game is over

    print_game(selected);      // Print the current game state
    get_command();             // Get the user's command
    compute_all_clues(selected, &selection_clues); // Recompute clues
    goto game_loop_start;      // Repeat the loop

    game_loop_end:
    print_game(selected);      // Final print of the game to show the winning state
}


/////////////////// Subset 2 ////////////////////

// This is used later in make_move, it converts letter inputs into
// numbers. Returns `previous` if the input is out of range.
int decode_coordinate(char input, char base, int maximum, int previous) {
    // Check if the input is in the valid range
    if (input < base || input >= base + maximum) {
        goto return_previous; // If not valid, jump to return previous
    }

    return input - base; // Return the decoded coordinate

return_previous:
    return previous; // Return the previous value if invalid
}

// Reads the coordinates of the solution to determine what the clues should be
void read_solution(void) {
    printf("Enter solution: ");

    int total = 0;
    int row, col;

read_input:
    scanf("%d", &row);
    scanf("%d", &col);

    if (row < 0 || col < 0) {
        goto finish_input; // If either row or col is negative, exit the loop
    }

    // Mark the solution grid with the coordinates entered
    solution[row % height][col % width] = MARKED;
    total++;
    
    // Continue reading more coordinates
    goto read_input;

finish_input:
    compute_all_clues(solution, &solution_clues);
    displayed_clues = &solution_clues;

    // Print out the total number of coordinates read
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
    int col = 0;
    int row = 0;

compute_vertical_clue:
    if (col >= width) {
        goto compute_horizontal_clue;
    }
    compute_clue(col, TRUE, grid, clues->vertical_clues[col]);
    col++;
    goto compute_vertical_clue;

compute_horizontal_clue:
    if (row >= height) {
        return;
    }
    compute_clue(row, FALSE, grid, clues->horizontal_clues[row]);
    row++;
    goto compute_horizontal_clue;
}


/////////////////// Subset 3 ////////////////////

// Prompt for, and then execute, a move
void make_move(void) {
    char first_letter, second_letter;
    int row, col;

get_coordinates:
    row = col = -1;  // Reset values

    // Get coordinates from user
    printf("Enter first coord: ");
    scanf(" %c", &first_letter);
    printf("Enter second coord: ");
    scanf(" %c", &second_letter);

    // Try decoding both coordinates for row and column
    col = decode_coordinate(first_letter, 'A', width, col);
    col = decode_coordinate(second_letter, 'A', width, col);
    row = decode_coordinate(first_letter, 'a', height, row);
    row = decode_coordinate(second_letter, 'a', height, row);

    // If coordinates are invalid, retry
    if (row == -1 || col == -1) {
        printf("Bad input, try again!\n");
        goto get_coordinates;
    }

get_choice:
    // Ask the user for their desired action on the cell
    printf("Enter choice (# to select, x to cross out, . to deselect): ");
    char choice;
    scanf(" %c", &choice);

    // Determine the new cell value based on input
    if (choice == '#') {
        selected[row][col] = MARKED;
    } else if (choice == 'x') {
        selected[row][col] = CROSSED_OUT;
    } else if (choice == '.') {
        selected[row][col] = UNMARKED;
    } else {
        printf("Bad input, try again!\n");
        goto get_choice;
    }
}


void print_game(char grid[MAX_HEIGHT][MAX_WIDTH]) {
    if (displayed_clues == &selection_clues) {
        printf("[printing counts for current selection rather than solution clues]\n");
    }

    int vertical_gutter = (height + 1) / 2;
    int horizontal_gutter = width + 1;

    int gutter_row = 0, gutter_col = 0, col = 0, row = 0;

    // Print the vertical gutter
    print_vertical_gutter:
    if (gutter_row < vertical_gutter) {
        // Print the space to the left of top clues
        print_gutter_col_space:
        if (gutter_col <= horizontal_gutter) {
            putchar(' ');
            gutter_col++;
            goto print_gutter_col_space;
        }
        
        // Print the top clues
        gutter_col = 0;
        print_top_clues:
        if (col < width) {
            putchar(lookup_clue(displayed_clues->vertical_clues[col], gutter_row, 0));
            col++;
            goto print_top_clues;
        }
        putchar('\n');
        gutter_row++;
        col = 0;
        goto print_vertical_gutter;
    }

    // Print the top coordinate reference (ABCDEF...)
    col = 0;
    print_top_coord_ref:
    if (col < horizontal_gutter + width + 1) {
        if (col <= horizontal_gutter) {
            putchar(' ');
        } else {
            putchar('A' + (col - horizontal_gutter - 1));
        }
        col++;
        goto print_top_coord_ref;
    }
    putchar('\n');

    // Print the grid with rows and clues
    row = 0;
    print_grid:
    if (row < height) {
        // Print this row's horizontal gutter
        gutter_col = 0;
        print_row_gutter:
        if (gutter_col < horizontal_gutter) {
            putchar(lookup_clue(displayed_clues->horizontal_clues[row], gutter_col, 1));
            gutter_col++;
            goto print_row_gutter;
        }

        // Print this row's coordinate reference letter
        putchar('a' + row);

        // Print the grid for this row
        col = 0;
        print_row_grid:
        if (col < width) {
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
            col++;
            goto print_row_grid;
        }

        putchar('\n');
        row++;
        goto print_grid;
    }
}

// Calculate a single row/column of a horizontal or vertical clue
void compute_clue(int index, int is_vertical, char grid[MAX_HEIGHT][MAX_WIDTH], int *clues) {
    int row = 0, col = 0, dx = 0, dy = 0, clue_index = 0, run_length = 0, i = 0;

    // Set direction based on vertical or horizontal
    if (is_vertical) {
        col = index;
        dy = 1;
    } else {
        row = index;
        dx = 1;
    }

    // Begin scanning the grid
start_scan:
    if (i >= (is_vertical ? height : width)) goto check_final_run;

    // If a MARKED cell is found, increase the run length
    if (grid[row][col] == MARKED) {
        run_length++;
    } else if (run_length) {
        // End of a run, store the clue
        clues[clue_index++] = run_length;
        run_length = 0;
    }

    // Move to the next cell
    row += dy;
    col += dx;
    i++;
    goto start_scan;

check_final_run:
    // If the last run hasn't been stored, store it
    if (run_length) {
        clues[clue_index++] = run_length;
    }

    // Fill remaining clues with 0
fill_clues:
    if (clue_index >= (is_vertical ? (height + 1) / 2 : (width + 1) / 2)) goto shift_clues;
    clues[clue_index++] = 0;
    goto fill_clues;

shift_clues:
    // Shift clues to the end of the array
    i = (is_vertical ? (height + 1) / 2 : (width + 1) / 2) - 1;
    int shift = i + 1 - clue_index;
shift_loop:
    if (i < 0) return;
    clues[i] = (i >= shift) ? clues[i - shift] : 0;
    i--;
    goto shift_loop;
}


// And finally one last function (a bit easier than the previous two!)
// so the game ends once the user solves the puzzle
int is_game_over(void) {
    int row = 0, col = 0;

check_vertical:
    if (row >= MAX_HEIGHT) goto check_horizontal;
    if (col >= MAX_WIDTH) {
        row++;
        col = 0;
        goto check_vertical;
    }

    if (selection_clues.vertical_clues[col][row] != solution_clues.vertical_clues[col][row]) {
        return FALSE;
    }

    col++;
    goto check_vertical;

check_horizontal:
    row = 0;
    col = 0;

check_horizontal_again:
    if (row >= MAX_HEIGHT) return TRUE;
    if (col >= MAX_WIDTH) {
        row++;
        col = 0;
        goto check_horizontal_again;
    }

    if (selection_clues.horizontal_clues[row][col] != solution_clues.horizontal_clues[row][col]) {
        return FALSE;
    }

    col++;
    goto check_horizontal_again;
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
