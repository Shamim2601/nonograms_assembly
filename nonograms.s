########################################################################
# COMP1521 24T3 -- Assignment 1 -- Nonograms!
#
#
# !!! IMPORTANT !!!
# Before starting work on the assignment, make sure you set your tab-width to 8!
# It is also suggested to indent with tabs only.
# Instructions to configure your text editor can be found here:
#   https://cgi.cse.unsw.edu.au/~cs1521/24T3/resources/mips-editors.html
# !!! IMPORTANT !!!
#
#
# This program was written by YOUR-NAME-HERE (z5555555)
# on INSERT-DATE-HERE
#
# Version 1.0 (2024-09-25): Team COMP1521 <cs1521@cse.unsw.edu.au>
#
########################################################################

#![tabsize(8)]

# ##########################################################
# ####################### Constants ########################
# ##########################################################

# C constants

TRUE = 1
FALSE = 0

MAX_WIDTH = 12
MAX_HEIGHT = 10

UNMARKED = 1
MARKED = 2
CROSSED_OUT = 3

# Other useful constants (feel free to add more if you want)

SIZEOF_CHAR = 1
SIZEOF_INT = 4

CLUE_SET_VERTICAL_CLUES_OFFSET = 0
CLUE_SET_HORIZONTAL_CLUES_OFFSET = CLUE_SET_VERTICAL_CLUES_OFFSET + SIZEOF_INT * MAX_WIDTH * MAX_HEIGHT
SIZEOF_CLUE_SET = CLUE_SET_HORIZONTAL_CLUES_OFFSET + SIZEOF_INT * MAX_HEIGHT * MAX_WIDTH

	.data
# ##########################################################
# #################### Global variables ####################
# ##########################################################

# !!! DO NOT ADD, REMOVE, OR MODIFY ANY OF THESE         !!!
# !!! DEFINITIONS OR ANY OTHER PART OF THE DATA SEGMENT  !!!

width:					# int width;
	.word	0

height:					# int height;
	.word	0

selected:				# char selected[MAX_HEIGHT][MAX_WIDTH];
	.byte	0:MAX_HEIGHT*MAX_WIDTH

solution:				# char solution[MAX_HEIGHT][MAX_WIDTH];
	.byte	0:MAX_HEIGHT*MAX_WIDTH

	.align	2
selection_clues:			# struct clue_set selection_clues;
	.byte	0:SIZEOF_CLUE_SET

solution_clues:				# struct clue_set solution_clues;
	.byte	0:SIZEOF_CLUE_SET

displayed_clues:			# struct clue_set *displayed_clues;
	.word	0

# ##########################################################
# ######################### Strings ########################
# ##########################################################

# !!! DO NOT ADD, REMOVE, OR MODIFY ANY OF THE      !!!
# !!! STRINGS OR ANY OTHER PART OF THE DATA SEGMENT !!!

str__main__height:
	.asciiz	"height"
str__main__width:
	.asciiz	"width"
str__main__congrats:
	.asciiz	"Congrats, you won!\n"

str__prompt_for_dimension__enter_the:
	.asciiz	"Enter the "
str__prompt_for_dimension__colon:
	.asciiz	": "
str__prompt_for_dimension__too_small:
	.asciiz	"error: too small, the minimum "
str__prompt_for_dimension__is:
	.asciiz	" is "
str__prompt_for_dimension__too_big:
	.asciiz	"error: too big, the maximum "

str__read_solution__enter_solution:
	.asciiz	"Enter solution: "

str__read_solution__loaded:
	.asciiz	"Loaded "
str__read_solution__solution_coordinates:
	.asciiz	" solution coordinates\n"

str__make_move__enter_first_coord:
	.asciiz	"Enter first coord: "
str__make_move__enter_second_coord:
	.asciiz	"Enter second coord: "
str__make_move__bad_input:
	.asciiz	"Bad input, try again!\n"
str__make_move__enter_choice:
	.asciiz	"Enter choice (# to select, x to cross out, . to deselect): "

str__print_game__printing_selection:
	.asciiz	"[printing counts for current selection rather than solution clues]\n"

str__dump_game_state__width:
	.asciiz	"width = "
str__dump_game_state__height:
	.asciiz	", height = "
str__dump_game_state__selected:
	.asciiz	"selected:\n"
str__dump_game_state__solution:
	.asciiz	"solution:\n"
str__dump_game_state__clues_vertical:
	.asciiz	"displayed_clues vertical:\n"
str__dump_game_state__clues_horizontal:
	.asciiz	"displayed_clues horizontal:\n"

str__get_command__prompt:
	.asciiz	" >> "
str__get_command__bad_command:
	.asciiz	"Bad command\n"

# !!! Reminder to not not add to or modify any of the above !!!
# !!! strings or any other part of the data segment.        !!!
# !!! If you add more strings you will likely break the     !!!
# !!! autotests and automarking.                            !!!


############################################################
####                                                    ####
####   Your journey begins here, intrepid adventurer!   ####
####                                                    ####
############################################################

################################################################################
#
# Implement the following functions, and check these boxes as you finish
# implementing each function.
#
#  SUBSET 1
#  - [ ] main
#  - [ ] prompt_for_dimension
#  - [ ] initialise_game
#  - [ ] game_loop
#  SUBSET 2
#  - [ ] decode_coordinate
#  - [ ] read_solution
#  - [ ] lookup_clue
#  - [ ] compute_all_clues
#  SUBSET 3
#  - [ ] make_move
#  - [ ] print_game
#  - [ ] compute_clue
#  - [ ] is_game_over
#  PROVIDED
#  - [X] get_command
#  - [X] dump_game_state


################################################################################
# .TEXT <main>
        .text
main:
	# Subset:   1
	#
	# Frame:    32
	# Uses:     $a0, $a1, $a2, $v0, $ra
	# Clobbers: $t0, $t1, $t2, $t3
	#
	# Locals:
	#   - height
	#   - width
	#
	# Structure:
	#   main
	#   -> [prologue]
	#     -> prompt_for_dimension (height)
	#     -> prompt_for_dimension (width)
	#     -> initialise_game
	#     -> read_solution
	#     -> game_loop
	#   -> [epilogue]

main__prologue:
	addi    $sp, $sp, -32
	sw      $ra, 28($sp)
	sw      $s0, 24($sp)
	sw      $s1, 20($sp)
	sw      $s2, 16($sp)
	sw      $s3, 12($sp)
	sw      $s4, 8($sp)
	sw      $s5, 4($sp)
	sw      $s6, 0($sp)
	
	li      $s0, 0              # height
	li      $s1, 0              # width
	
	la      $a0, height_str
	li      $a1, 3
	li      $a2, MAX_HEIGHT
	la      $a3, height
	jal     prompt_for_dimension

	la      $a0, width_str
	li      $a1, 3
	li      $a2, MAX_WIDTH
	la      $a3, width
	jal     prompt_for_dimension

	jal     initialise_game
	jal     read_solution
	
	li      $v0, 11
	li      $a0, '\n'
	syscall
	
	jal     game_loop

	la      $a0, congrats_str
	li      $v0, 4
	syscall

main__epilogue:
	lw      $ra, 28($sp)
	lw      $s0, 24($sp)
	lw      $s1, 20($sp)
	lw      $s2, 16($sp)
	lw      $s3, 12($sp)
	lw      $s4, 8($sp)
	lw      $s5, 4($sp)
	lw      $s6, 0($sp)
	addi    $sp, $sp, 32
	jr      $ra


################################################################################
# .TEXT <prompt_for_dimension>
        .text
prompt_for_dimension:
	# Subset:   1
	#
	# Frame:    32 bytes for storing $ra, saved registers, and local variables
	# Uses:     $a0, $a1, $a2, $a3, $v0, $t0, $t1
	# Clobbers: $v0, $t0, $t1
	#
	# Locals:   
	#   - input (stored in $t0)
	#
	# Structure:        
	#   prompt_for_dimension
	#   -> [prologue]
	#     -> body
	#   -> [epilogue]

prompt_for_dimension__prologue:
    addi    $sp, $sp, -32       # Allocate stack frame
    sw      $ra, 28($sp)        # Save return address
    sw      $s0, 24($sp)        # Save $s0 (used for min)
    sw      $s1, 20($sp)        # Save $s1 (used for max)
    sw      $s2, 16($sp)        # Save $s2 (used for pointer)
    move    $s0, $a1            # Save min into $s0
    move    $s1, $a2            # Save max into $s1
    move    $s2, $a3            # Save pointer into $s2

prompt_for_dimension__body:
prompt_for_dimension__loop:
    # Print the prompt message: "Enter the name: "
    la      $a0, str__prompt_for_dimension__enter_the # Load "Enter the " string
    li      $v0, 4                 # Syscall code for print_string
    syscall                        # Print "Enter the "

    move    $a0, $a0               # Name is already in $a0 from function call
    li      $v0, 4                 # Syscall code for print_string
    syscall                        # Print name

    la      $a0, str__prompt_for_dimension__colon   # Load ": " string
    li      $v0, 4                 # Syscall code for print_string
    syscall                        # Print ": "

    # Read integer input
    li      $v0, 5                 # Syscall code for read_int
    syscall                        # Read input
    move    $t0, $v0               # Store the input in $t0

    # Check if input is too small
    blt     $t0, $s0, prompt_for_dimension__too_small

    # Check if input is too big
    bgt     $t0, $s1, prompt_for_dimension__too_big

    # Input is valid, store it in the address pointed to by $s2
    sw      $t0, 0($s2)
    j       prompt_for_dimension__exit

prompt_for_dimension__too_small:
    # Print error message: "error: too small, the minimum name is min\n"
    la      $a0, str__prompt_for_dimension__too_small  # Load error message
    li      $v0, 4                 # Syscall code for print_string
    syscall                        # Print the error message

    move    $a0, $a0               # Print the name again
    li      $v0, 4                 # Syscall code for print_string
    syscall                        # Print name

    la      $a0, str__prompt_for_dimension__is   # Load " is " string
    li      $v0, 4                 # Syscall code for print_string
    syscall                        # Print " is "

    move    $a0, $s0               # Load min value
    li      $v0, 1                 # Syscall code for print_int
    syscall                        # Print the minimum value

    li      $a0, '\n'              # Load newline character
    li      $v0, 11                # Syscall code for print_char
    syscall                        # Print newline
    j       prompt_for_dimension__loop

prompt_for_dimension__too_big:
    # Print error message: "error: too big, the maximum name is max\n"
    la      $a0, str__prompt_for_dimension__too_big  # Load error message
    li      $v0, 4                 # Syscall code for print_string
    syscall                        # Print the error message

    move    $a0, $a0               # Print the name again
    li      $v0, 4                 # Syscall code for print_string
    syscall                        # Print name

    la      $a0, str__prompt_for_dimension__is   # Load " is " string
    li      $v0, 4                 # Syscall code for print_string
    syscall                        # Print " is "

    move    $a0, $s1               # Load max value
    li      $v0, 1                 # Syscall code for print_int
    syscall                        # Print the maximum value

    li      $a0, '\n'              # Load newline character
    li      $v0, 11                # Syscall code for print_char
    syscall                        # Print newline
    j       prompt_for_dimension__loop

prompt_for_dimension__exit:
prompt_for_dimension__epilogue:
    lw      $ra, 28($sp)        # Restore $ra
    lw      $s0, 24($sp)        # Restore $s0
    lw      $s1, 20($sp)        # Restore $s1
    lw      $s2, 16($sp)        # Restore $s2
    addi    $sp, $sp, 32        # Restore stack pointer
    jr      $ra                 # Return to caller


################################################################################
# .TEXT <initialise_game>
        .text
initialise_game:
	# Subset:   1
	#
	# Frame:    [...]   <-- FILL THESE OUT!
	# Uses:     [...]
	# Clobbers: [...]
	#
	# Locals:           <-- FILL THIS OUT!
	#   - ...
	#
	# Structure:        <-- FILL THIS OUT!
	#   initialise_game
	#   -> [prologue]
	#     -> body
	#   -> [epilogue]

initialise_game__prologue:

initialise_game__body:

initialise_game__epilogue:
	jr      $ra


################################################################################
# .TEXT <game_loop>
        .text
game_loop:
	# Subset:   1
	#
	# Frame:    [...]   <-- FILL THESE OUT!
	# Uses:     [...]
	# Clobbers: [...]
	#
	# Locals:           <-- FILL THIS OUT!
	#   - ...
	#
	# Structure:        <-- FILL THIS OUT!
	#   game_loop
	#   -> [prologue]
	#     -> body
	#   -> [epilogue]

game_loop__prologue:

game_loop__body:

game_loop__epilogue:
	jr      $ra


################################################################################
# .TEXT <decode_coordinate>
        .text
decode_coordinate:
	# Subset:   2
	#
	# Frame:    [...]   <-- FILL THESE OUT!
	# Uses:     [...]
	# Clobbers: [...]
	#
	# Locals:           <-- FILL THIS OUT!
	#   - ...
	#
	# Structure:        <-- FILL THIS OUT!
	#   decode_coordinate
	#   -> [prologue]
	#     -> body
	#   -> [epilogue]

decode_coordinate__prologue:

decode_coordinate__body:

decode_coordinate__epilogue:
	jr      $ra


################################################################################
# .TEXT <read_solution>
        .text
read_solution:
	# Subset:   2
	#
	# Frame:    [...]   <-- FILL THESE OUT!
	# Uses:     [...]
	# Clobbers: [...]
	#
	# Locals:           <-- FILL THIS OUT!
	#   - ...
	#
	# Structure:        <-- FILL THIS OUT!
	#   read_solution
	#   -> [prologue]
	#     -> body
	#   -> [epilogue]

read_solution__prologue:

read_solution__body:

read_solution__epilogue:
	jr      $ra


################################################################################
# .TEXT <lookup_clue>
        .text
lookup_clue:
	# Subset:   2
	#
	# Frame:    [...]   <-- FILL THESE OUT!
	# Uses:     [...]
	# Clobbers: [...]
	#
	# Locals:           <-- FILL THIS OUT!
	#   - ...
	#
	# Structure:        <-- FILL THIS OUT!
	#   lookup_clue
	#   -> [prologue]
	#     -> body
	#   -> [epilogue]

lookup_clue__prologue:

lookup_clue__body:

lookup_clue__epilogue:
	jr      $ra


################################################################################
# .TEXT <compute_all_clues>
        .text
compute_all_clues:
	# Subset:   2
	#
	# Frame:    [...]   <-- FILL THESE OUT!
	# Uses:     [...]
	# Clobbers: [...]
	#
	# Locals:           <-- FILL THIS OUT!
	#   - ...
	#
	# Structure:        <-- FILL THIS OUT!
	#   compute_all_clues
	#   -> [prologue]
	#     -> body
	#   -> [epilogue]

compute_all_clues__prologue:

compute_all_clues__body:

compute_all_clues__epilogue:
	jr      $ra


################################################################################
# .TEXT <make_move>
        .text
make_move:
	# Subset:   3
	#
	# Frame:    [...]   <-- FILL THESE OUT!
	# Uses:     [...]
	# Clobbers: [...]
	#
	# Locals:           <-- FILL THIS OUT!
	#   - ...
	#
	# Structure:        <-- FILL THIS OUT!
	#   make_move
	#   -> [prologue]
	#     -> body
	#   -> [epilogue]

make_move__prologue:

make_move__body:

make_move__epilogue:
	jr      $ra


################################################################################
# .TEXT <print_game>
        .text
print_game:
	# Subset:   3
	#
	# Frame:    [...]   <-- FILL THESE OUT!
	# Uses:     [...]
	# Clobbers: [...]
	#
	# Locals:           <-- FILL THIS OUT!
	#   - ...
	#
	# Structure:        <-- FILL THIS OUT!
	#   print_game
	#   -> [prologue]
	#     -> body
	#   -> [epilogue]

print_game__prologue:

print_game__body:

print_game__epilogue:
	jr      $ra


################################################################################
# .TEXT <compute_clue>
        .text
compute_clue:
	# Subset:   3
	#
	# Frame:    [...]   <-- FILL THESE OUT!
	# Uses:     [...]
	# Clobbers: [...]
	#
	# Locals:           <-- FILL THIS OUT!
	#   - ...
	#
	# Structure:        <-- FILL THIS OUT!
	#   compute_clue
	#   -> [prologue]
	#     -> body
	#   -> [epilogue]

compute_clue__prologue:

compute_clue__body:

compute_clue__epilogue:
	jr      $ra


################################################################################
# .TEXT <is_game_over>
        .text
is_game_over:
	# Subset:   3
	#
	# Frame:    [...]   <-- FILL THESE OUT!
	# Uses:     [...]
	# Clobbers: [...]
	#
	# Locals:           <-- FILL THIS OUT!
	#   - ...
	#
	# Structure:        <-- FILL THIS OUT!
	#   is_game_over
	#   -> [prologue]
	#     -> body
	#   -> [epilogue]

is_game_over__prologue:

is_game_over__body:

is_game_over__epilogue:
	jr      $ra


################################################################################
################################################################################
###                   PROVIDED FUNCTIONS — DO NOT CHANGE                     ###
################################################################################
################################################################################

################################################################################
# .TEXT <get_command>
        .text
get_command:
	# Provided
	#
	# Frame:    [$ra]
	# Uses:     [$a0, $v0, $t0, $t1]
	# Clobbers: [$a0, $v0, $t0, $t1]
	#
	# Locals:
	#   - $t0: command
	#   - $t1: &selection_clues or &solution_clues
	#
	# Structure:
	# Structure:
	#   dump_game_state
	#   -> [prologue]
	#   -> body
	#     -> command_m
	#     -> command_q
	#     -> command_d
	#     -> command_s
	#     -> command_S
	#     -> command_query
	#     -> bad_command
	#   -> [epilogue]

get_command__prologue:
	begin
	push	$ra

get_command__body:
	li	$v0, 4					# syscall 4: print_string
	li	$a0, str__get_command__prompt
	syscall						# printf(" >> ");

	li	$v0, 12					# syscall 12: read_char
	syscall
	move	$t0, $v0				# scanf(" %c", &command);

	beq	$t0, 'm', get_command__command_m	# if (command == 'm') { ...
	beq	$t0, 'q', get_command__command_q	# } else if (command == 'q') { ...
	beq	$t0, 'd', get_command__command_d	# } else if (command == 'd') { ...
	beq	$t0, 's', get_command__command_s	# } else if (command == 's') { ...
	beq	$t0, 'S', get_command__command_S	# } else if (command == 'S') { ...
	beq	$t0, '?', get_command__command_query	# } else if (command == '?') { ...
	b	get_command__bad_command		# } else { ... }

get_command__command_m:					# if (command == 'm') {
	jal	make_move				#   make_move();
	b	get_command__epilgoue			# }

get_command__command_q:					# else if (command == 'q') {
	li	$v0, 10					#   syscall 10: exit
	syscall						#   exit(0);
	b	get_command__epilgoue			# }

get_command__command_d:					# if (command == 'd') {
	jal	dump_game_state				#   dump_game_state();
	b	get_command__epilgoue			# }

get_command__command_s:					# else if (command == 's') {
	la	$t1, selection_clues			#   &selection_clues
	sw	$t1, displayed_clues			#   displayed_clues = &selection_clues;
	b	get_command__epilgoue			# }

get_command__command_S:					# else if (command == 'S') {
	la	$t1, solution_clues			#   &solution_clues
	sw	$t1, displayed_clues			#   displayed_clues = &solution_clues;
	b	get_command__epilgoue			# }

get_command__command_query:				# else if (command == '?') {
	la	$a0, solution				#   solution
	jal	print_game				#   print_game(solution);
	b	get_command__epilgoue			# }

get_command__bad_command:				# else {
	li	$v0, 4					#   syscall 4: print_string
	la	$a0, str__get_command__bad_command	#   printf("Bad command");
	syscall

get_command__epilgoue:					# }
	pop	$ra
	end
	jr	$ra					# return;


################################################################################
# .TEXT <dump_game_state>
        .text
dump_game_state:
	# Provided
	#
	# Frame:    []
	# Uses:     [$a0, $v0, $t0, $t1, $t2, $t3]
	# Clobbers: [$a0, $v0, $t0, $t1, $t2, $t3]
	#
	# Locals:
	#   - $t0: row
	#   - $t1: col
	#   - $t2: copy of width/height/displayed_clues
	#   - $t3: temporary address calculations
	#
	# Structure:
	#   dump_game_state
	#   -> [prologue]
	#   -> body
	#     -> loop_selected_row__init
	#     -> loop_selected_row__cond
	#     -> loop_selected_row__body
	#       -> loop_selected_col__init
	#       -> loop_selected_col__cond
	#       -> loop_selected_col__body
	#       -> loop_selected_col__step
	#       -> loop_selected_col__end
	#     -> loop_selected_row__step
	#     -> loop_selected_row__end
	#     -> loop_solution_row__init
	#     -> loop_solution_row__cond
	#     -> loop_solution_row__body
	#       -> loop_solution_col__init
	#       -> loop_solution_col__cond
	#       -> loop_solution_col__body
	#       -> loop_solution_col__step
	#       -> loop_solution_col__end
	#     -> loop_solution_row__step
	#     -> loop_solution_row__end
	#     -> loop_clues_vert_row__init
	#     -> loop_clues_vert_row__cond
	#     -> loop_clues_vert_row__body
	#       -> loop_clues_vert_col__init
	#       -> loop_clues_vert_col__cond
	#       -> loop_clues_vert_col__body
	#       -> loop_clues_vert_col__step
	#       -> loop_clues_vert_col__end
	#     -> loop_clues_vert_row__step
	#     -> loop_clues_vert_row__end
	#     -> loop_clues_horiz_row__init
	#     -> loop_clues_horiz_row__cond
	#     -> loop_clues_horiz_row__body
	#       -> loop_clues_horiz_col__init
	#       -> loop_clues_horiz_col__cond
	#       -> loop_clues_horiz_col__body
	#       -> loop_clues_horiz_col__step
	#       -> loop_clues_horiz_col__end
	#     -> loop_clues_horiz_row__step
	#     -> loop_clues_horiz_row__end
	#   -> [epilogue]


dump_game_state__prologue:
	begin

dump_game_state__body:
	li	$v0, 4					# syscall 4: print_string
	li	$a0, str__dump_game_state__width
	syscall						# printf("width = ");

	li	$v0, 1					# syscall 1: print_int
	lw	$a0, width				# width
	syscall						# printf("%d", width);

	li	$v0, 4					# syscall 4: print_string
	li	$a0, str__dump_game_state__height
	syscall						# printf("height = ");

	li	$v0, 1					# syscall 1: print_int
	lw	$a0, height				# height
	syscall						# printf("%d", height);

	li	$v0, 11					# syscall 11: print_char
	li	$a0, '\n'
	syscall						# printf("%c", '\n');

	li	$v0, 4					# syscall 4: print_string
	li	$a0, str__dump_game_state__selected
	syscall						# printf("selected:\n");

dump_game_state__loop_selected_row__init:
	li	$t0, 0					# int row = 0;

dump_game_state__loop_selected_row__cond:		# while (row < height) {
	lw	$t2, height
	bge	$t0, $t2, dump_game_state__loop_selected_row__end

dump_game_state__loop_selected_row__body:
dump_game_state__loop_selected_col__init:
	li	$t1, 0					#   int col = 0;

dump_game_state__loop_selected_col__cond:		#   while (col < width) {
	lw	$t2, width
	bge	$t1, $t2, dump_game_state__loop_selected_col__end

dump_game_state__loop_selected_col__body:
	mul	$t3, $t0, MAX_WIDTH			#     row * MAX_WIDTH
	add	$t3, $t3, $t1				#     row * MAX_WIDTH + col
	add	$t3, $t3, selected			#     selected + row * MAX_WIDTH + col
							#      == &selected[row][col]

	li	$v0, 1					#     syscall 1: print_int
	lb	$a0, ($t3)				#     selected[row][col]
	syscall						#     printf("%d", selected[row][col]);

	li	$v0, 11					#     syscall 11: print_char
	li	$a0, ' '
	syscall						#     printf("%c", ' ');

dump_game_state__loop_selected_col__step:
	addi	$t1, $t1, 1				#     col++;
	b	dump_game_state__loop_selected_col__cond

dump_game_state__loop_selected_col__end:		#   }

	li	$v0, 11					#   syscall 11: print_char
	li	$a0, '\n'
	syscall						#   printf("%c", '\n');

dump_game_state__loop_selected_row__step:
	addi	$t0, $t0, 1				#   row++;
	b	dump_game_state__loop_selected_row__cond

dump_game_state__loop_selected_row__end:		# }


	li	$v0, 4					# syscall 4: print_string
	li	$a0, str__dump_game_state__solution
	syscall						# printf("solution:\n");

dump_game_state__loop_solution_row__init:
	li	$t0, 0					# int row = 0;

dump_game_state__loop_solution_row__cond:		# while (row < height) {
	lw	$t2, height
	bge	$t0, $t2, dump_game_state__loop_solution_row__end

dump_game_state__loop_solution_row__body:
dump_game_state__loop_solution_col__init:
	li	$t1, 0					#   int col = 0;

dump_game_state__loop_solution_col__cond:		#   while (col < width) {
	lw	$t2, width
	bge	$t1, $t2, dump_game_state__loop_solution_col__end

dump_game_state__loop_solution_col__body:
	mul	$t3, $t0, MAX_WIDTH			#     row * MAX_WIDTH
	add	$t3, $t3, $t1				#     row * MAX_WIDTH + col
	add	$t3, $t3, solution			#     solution + row * MAX_WIDTH + col
							#      == &solution[row][col]

	li	$v0, 1					#     syscall 1: print_int
	lb	$a0, ($t3)				#     solution[row][col]
	syscall						#     printf("%d", solution[row][col]);

	li	$v0, 11					#     syscall 11: print_char
	li	$a0, ' '
	syscall						#     printf("%c", ' ');

dump_game_state__loop_solution_col__step:
	addi	$t1, $t1, 1				#     col++;
	b	dump_game_state__loop_solution_col__cond

dump_game_state__loop_solution_col__end:		#   }

	li	$v0, 11					#   syscall 11: print_char
	li	$a0, '\n'
	syscall						#   printf("%c", '\n');

dump_game_state__loop_solution_row__step:
	addi	$t0, $t0, 1				#   row++;
	b	dump_game_state__loop_solution_row__cond

dump_game_state__loop_solution_row__end:		# }

	li	$v0, 4					# syscall 4: print_string
	li	$a0, str__dump_game_state__clues_vertical
	syscall						# printf("displayed_clues vertical:\n");

dump_game_state__loop_clues_vert_row__init:
	li	$t0, 0					# int row = 0;

dump_game_state__loop_clues_vert_row__cond:		# while (row < MAX_HEIGHT) {
	bge	$t0, MAX_HEIGHT, dump_game_state__loop_clues_vert_row__end

dump_game_state__loop_clues_vert_row__body:
dump_game_state__loop_clues_vert_col__init:
	li	$t1, 0					#   int col = 0;

dump_game_state__loop_clues_vert_col__cond:		#   while (col < MAX_WIDTH) {
	bge	$t1, MAX_WIDTH, dump_game_state__loop_clues_vert_col__end

dump_game_state__loop_clues_vert_col__body:
	mul	$t3, $t1, MAX_HEIGHT			#     col * MAX_HEIGHT
	add	$t3, $t3, $t0				#     col * MAX_HEIGHT + row
	mul	$t3, $t3, SIZEOF_INT			#     4 * (col * MAX_HEIGHT + row)
	lw	$t2, displayed_clues			#     displayed_clues
	add	$t3, $t3, $t2				#     displayed_clues + 4 * (col * MAX_HEIGHT + row)

	addi	$t3, CLUE_SET_VERTICAL_CLUES_OFFSET	#     &displayed_clues->vertical_clues[col][row]

	lw	$a0, ($t3)				#     displayed_clues->vertical_clues[col][row]
	li	$v0, 1					#     syscall 1: print_int
	syscall						#     printf("%d", displayed_clues->vertical_clues[col][row]);

	li	$v0, 11					#     syscall 11: print_char
	li	$a0, ' '
	syscall						#     printf("%c", ' ');

dump_game_state__loop_clues_vert_col__step:
	addi	$t1, $t1, 1				#     col++;
	b	dump_game_state__loop_clues_vert_col__cond

dump_game_state__loop_clues_vert_col__end:		#   }

	li	$v0, 11					#   syscall 11: print_char
	li	$a0, '\n'
	syscall						#   printf("%c", '\n');

dump_game_state__loop_clues_vert_row__step:
	addi	$t0, $t0, 1				#   row++;
	b	dump_game_state__loop_clues_vert_row__cond

dump_game_state__loop_clues_vert_row__end:		# }

	li	$v0, 4					# syscall 4: print_string
	li	$a0, str__dump_game_state__clues_horizontal
	syscall						# printf("displayed_clues horizontal:\n");

dump_game_state__loop_clues_horiz_row__init:
	li	$t0, 0					# int row = 0;

dump_game_state__loop_clues_horiz_row__cond:		# while (row < MAX_HEIGHT) {
	bge	$t0, MAX_HEIGHT, dump_game_state__loop_clues_horiz_row__end

dump_game_state__loop_clues_horiz_row__body:
dump_game_state__loop_clues_horiz_col__init:
	li	$t1, 0					#   int col = 0;

dump_game_state__loop_clues_horiz_col__cond:		#   while (col < MAX_WIDTH) {
	bge	$t1, MAX_WIDTH, dump_game_state__loop_clues_horiz_col__end

dump_game_state__loop_clues_horiz_col__body:
	mul	$t3, $t0, MAX_WIDTH			#     row * MAX_WIDTH
	add	$t3, $t3, $t1				#     row * MAX_WIDTH + col
	mul	$t3, $t3, SIZEOF_INT			#     4 * (row * MAX_WIDTH + col)
	lw	$t2, displayed_clues			#     displayed_clues
	add	$t3, $t3, $t2				#     displayed_clues + 4 * (row * MAX_WIDTH + col)
	addi	$t3, CLUE_SET_HORIZONTAL_CLUES_OFFSET	#     &displayed_clues->horizontal_clues[row][col]

	lw	$a0, ($t3)				#     displayed_clues->horizontal_clues[row][col]
	li	$v0, 1					#     syscall 1: print_int
	syscall						#     printf("%d", displayed_clues->horizontal_clues[row][col]);

	li	$v0, 11					#     syscall 11: print_char
	li	$a0, ' '
	syscall						#     printf("%c", ' ');

dump_game_state__loop_clues_horiz_col__step:
	addi	$t1, $t1, 1				#     col++;
	b	dump_game_state__loop_clues_horiz_col__cond

dump_game_state__loop_clues_horiz_col__end:		#   }

	li	$v0, 11					#   syscall 11: print_char
	li	$a0, '\n'
	syscall						#   printf("%c", '\n');

dump_game_state__loop_clues_horiz_row__step:
	addi	$t0, $t0, 1				#   row++;
	b	dump_game_state__loop_clues_horiz_row__cond

dump_game_state__loop_clues_horiz_row__end:		# }

dump_game_state__epilogue:
	end
	jr	$ra					# return;
