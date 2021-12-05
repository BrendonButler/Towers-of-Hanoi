# I, Brendon Butler, certify that this assignment is of my own work, based on my personal study.
.data

disk_prmpt:	.asciiz "How many disks would you like? "
peg_strt_prmpt: .asciiz "\nWhich peg would you like to start on (A, B, or C)? "
peg_dest_prmpt: .asciiz "\nWhich peg would you like to end on (A, B, or C)? "
try_again:	.asciiz	"\nYour source and destination cannot be the same, choose a different destination. Source: "
start_w_txt:	.asciiz "\nStarting with "
on_peg_txt:	.asciiz " on peg "
move_disk_txt:	.asciiz "Move disk from "
to_txt:		.asciiz " to "
with_tmp_txt:	.asciiz " with temp peg "

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

.macro 	print_char(%val)
	li	$a0, %val
	li	$v0, 11
	syscall
.end_macro

.macro 	print_char_at($val)
	la	$a0, ($val)
	li	$v0, 11
	syscall
.end_macro

.macro	usr_input(%val)			# 5 for integer, 8 for string
	la 	$v0, %val		# get user input
	syscall
.end_macro

# %n = number of disks, %src = source peg, %dest = destination peg, %temp = temp peg
.macro 	print_start(%n, %src, %dest, %temp)
	print_str(start_w_txt)
	print_int(%n)
	print_str(on_peg_txt)
	print_char_at(%src)
	print_str(to_txt)
	print_char_at(%dest)
	print_str(with_tmp_txt)
	print_char_at(%temp)
	print_char('.')
	print_char('\n')
.end_macro

.macro	print_move(%src, %dest)			# prints the output string in format "Move disk S to D"
	print_str(move_disk_txt)
	print_char_at(%src)
	print_str(to_txt)
	print_char_at(%dest)
	print_char('\n')			# print new line character
.end_macro
	# END OF MACROS, start of program

	print_str(disk_prmpt)			# prompt user for how many disks they want
	usr_input(5)				# get user input (int = 5)
	
	move 	$t0, $v0			# store number of disks into $t0 from input ($v0)

# prompt user for start peg
prompt_start_peg:
	print_str(peg_strt_prmpt)		# prompt what peg to start on A, B, or C
	usr_input(12)				# get user input (char = 12)
	
	blt	$v0, 'A', prompt_start_peg	# jump to start peg prompt on invalid input
	bgt	$v0, 'C', prompt_start_peg	# jump to start peg prompt on invalid input
	
	move	$t1, $v0			# set $t1 to initial peg ($v0 input)
	j	prompt_dest_peg

# if user enters the source and destination pegs that are identical, reprompt
try_again_dest:
	print_str(try_again)			# print try_again message
	print_char_at($t1)			# print source 
	print_char('\n')
	
# prompt user for destination peg
prompt_dest_peg:
	print_str(peg_dest_prmpt)		# prompt what peg to start on A, B, or C
	usr_input(12)				# get user input (char = 12)
	
	blt	$v0, 'A', prompt_dest_peg	# jump to start peg prompt on invalid input
	bgt	$v0, 'C', prompt_dest_peg	# jump to start peg prompt on invalid input
	beq	$v0, $t1, try_again_dest	# reprompt for second peg if source & destination are the same
	
	move	$t2, $v0			# set $t2 to destination peg ($t2)
	
	add	$t4, $t1, $t2			# add $t1 & $t2 to find temp peg value
	
	beq	$t4, 133, temp_A		# jump to set $t3 to 'A' if 'B' and 'C' are chosen for inputs
	beq	$t4, 132, temp_B		# jump to set $t3 to 'B' if 'A' and 'C' are chosen for inputs
	beq	$t4, 131, temp_C		# jump to set $t3 to 'C' if 'A' and 'B' are chosen for inputs
	
temp_A:
	li	$t3, 'A'			# set $t3 to temp peg (A)
	j	end_temp_set			# skip to end of setting temp peg
temp_B:
	li	$t3, 'B'			# set $t3 to temp peg (B)
	j	end_temp_set			# skip to end of setting temp peg
temp_C:
	li	$t3, 'C'
end_temp_set:
	# print "Starting with N on peg X."
	print_start($t0, $t1, $t2, $t3)
	
	push($t3)		# push $t3 (temp peg) onto stack for move_tower procedure
	push($t2)		# push $t2 (end peg) onto stack for move_tower procedure
	push($t1)		# push $t1 (start peg) onto stack for move_tower procedure
	push($t0)		# push $t0 (number of disks) onto stack for move_tower procedure
	
	jal	move_tower	# jump and link to move_tower procedure

	# END OF PROGRAM, exit value
	li 	$v0, 10
	syscall
	
	# FUNCTIONS
# MOVE TOWER | reg0 = n, reg1 = current disk, reg2 = source, reg3 = destination, reg4 = spare
# moveTower(int n, char 
# source, dest, and spare are the pegs for the disks to sit on
move_tower:
	push($ra)
	lw	$t0, 4($sp)		# load first value after $ra from $sp to $t0 (number of pegs)
	lw	$t1, 8($sp)		# load second value from $sp to $t1 (inital peg)
	lw 	$t2, 12($sp)		# load third value from $sp to $t2 (destination peg)
	lw	$t3, 16($sp)		# load the fourth value from $sp to $t3 (temp peg)
	
	beq	$t0, 1, base_case	# branch if $t0 is equal to 1 to perform the base case, else continue
	
	addiu	$t0, $t0, -1		# (n - 1) go to next move
	
	push($t2)		# backup $t2 as temp peg
	push($t3)		# backup $t3 as dest peg
	push($t1)		# backup $t1 as src peg
	push($t0)		# backup n from $t0
	
	jal	move_tower		# recursively jump and link to move_tower
	
	# pop values backed up before recursive call
	pop($t0)
	pop($t1)
	pop($t3)
	pop($t2)
	
	print_move($t1, $t2)		# print the move just made "Move peg S to D"
	
	push($t1)		# backup $t1 as temp peg
	push($t2)		# backup $t2 as dest peg
	push($t3)		# backup $t3 as src peg
	push($t0)		# backup n from $t0
	
	jal	move_tower
	
	# pop values backed up before recursive call
	pop($t0)
	pop($t3)
	pop($t2)
	pop($t1)
	
	j	done_moving		# jump to done_moving to skip base_case
	
base_case:			# if $t0 equals 1, print the base move $t1 -> $t2
	print_move($t1, $t2)
	
done_moving:
	pop($ra)			# restore $ra from stack
	jr $ra				# jump to return address
