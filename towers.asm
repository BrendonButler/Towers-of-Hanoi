# I, Brendon Butler, certify that this assignment is of my own work, based on my personal study.
.data

disk_prmpt:	.asciiz "How many disks would you like? "

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

.macro 	print_str(%val)			# print string values to the console
	la 	$a0, %val
	li 	$v0,	4
	syscall
.end_macro

.macro 	print_int(%val)			# print integer values to the console
	la 	$a0, (%val)
	li 	$v0, 1
	syscall
.end_macro

.macro	usr_input(%val)			# 5 for integer, 8 for string
	la 	$v0, %val		# get user input
	syscall
.end_macro

.macro	print_move(%src, %dest)		# prints the output string in format "SRC -> DEST"
	print_int(%src)
	li	$a0, '-'		# print hyphen
	li	$v0, 11
	syscall
	li	$a0, '>'		# print greater than sign
	li	$v0, 11
	syscall
	print_int(%dest)
	li	$a0, '\n'		# print new line character
	li	$v0, 11
	syscall
.end_macro
	# END OF MACROS, start of program

	print_str(disk_prmpt)	# prompt user for how many disks they want
	usr_input(5)
	
	# store number of disks into $t0 from input ($v0)
	move 	$t0, $v0
	li	$t1, 0		# set $t1 to initial peg (0)
	li	$t2, 2		# set $t2 to destination peg (2)
	li	$t3, 1		# set $t3 to temp peg (1)
	
	push($t3)		# push $t3 (temp peg) onto stack for move_tower procedure
	push($t2)		# push $t2 (end peg) onto stack for move_tower procedure
	push($t1)		# push $t1 (start peg) onto stack for move_tower procedure
	push($t0)		# push $t0 (number of disks) onto stack for move_tower procedure
	
	jal	move_tower	# jump and link to move_tower procedure

	# END OF PROGRAM, exit value
	li 	$v0, 10
	syscall
	
	# FUNCTIONS
# MOVE TOWER | reg1 = current disk, reg2 = source, reg3 = destination, reg4 = spare
# source, dest, and spare are the pegs for the disks to sit on
move_tower:
	push($ra)
	lw	$t0, 4($sp)		# load first value after $ra from $sp to $t0 (number of pegs)
	lw	$t1, 8($sp)		# load second value from $sp to $t1 (inital peg)
	lw 	$t2, 12($sp)		# load third value from $sp to $t2 (destination peg)
	lw	$t3, 16($sp)		# load the fourth value from $sp to $t3 (temp peg)
	
	beq	$t0, 1, base_case	# branch if $t0 is equal to 1 to perform the base case, else continue
	
	addiu	$t0, $t0, -1		# (n - 1) go to next move
	
	push($t2)
	push($t3)
	push($t1)
	push($t0)
	
	jal	move_tower
	
	pop($t0)
	pop($t1)
	pop($t3)
	pop($t2)
	
	print_move($t1, $t2)
	
	push($t1)
	push($t2)
	push($t3)
	push($t0)
	
	jal	move_tower
	
	pop($t0)
	pop($t3)
	pop($t2)
	pop($t1)
	
	j	done_moving
	
base_case:			# if $t0 equals 1, print the base move $t1 -> $t2
	print_move($t1, $t2)
	
done_moving:
	
	pop($ra)
	jr $ra
