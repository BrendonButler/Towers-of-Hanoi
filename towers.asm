# I, Brendon Butler, certify that this assignment is of my own work, based on my personal study.
.data

.text
main:
	# MACROS
.macro	push(%s)
	addiu 	$sp, $sp, -4 
	sw	%s, ($sp)
.end_macro

.macro	pop(%s)
	lw	%s, ($sp)
	addiu	$sp, $sp, 4
.end_macro
	# END OF MACROS, start of program

	# END OF PROGRAM, exit value
	li 	$v0, 10
	syscall
	
	# FUNCTIONS
# MOVE TOWER | reg1 = current disk, reg2 = source, reg3 = destination, reg4 = spare
# source, dest, and spare are the pegs for the disks to sit on
move_tower:
	
