#Ethan Payne 
#CS3340.0U1 Project: Reversi
	.data

newBoard: .byte	' ':64	#creates an empty board of 64 characters (to be used and modified)
BOARDTODRAW: .byte 'E':64	#creates an empty board of 64 characters (to be used and modified)
HEADER:	.asciiz "  | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |\n"	#label for each column
HLINE:	.asciiz "  +---+---+---+---+---+---+---+---+\n"	#horizontal line for board
VLINE:	.asciiz "  |   |   |   |   |   |   |   |   |\n"	#vertical line for board
SPACE:  .asciiz " "	#just a space for formatting	
COLSEP:	.asciiz "| "	#column seperator for formatting
COLSEP2:.asciiz "|\n"	#column seperator for formatting
	.text
DRAWBOARD:
	la $a0, newBoard
	la $t0, BOARDTODRAW
	# Print out the board received as argument ($a0)
	
	# Loop through 64 times to load all indices of board
	# Create counter for loop
	move $t7, $zero
MOVEBOARD:	
	# Move the full board from $a0
	# Iterate through indixes		
	lb $t8, ($a0)				#load the next byte from the board
	sb $t8, ($t0)				#set i($t0) to value of i($a0) (the board)
	
	add $a0, $a0, 1				#add offset to board address 
	add $t0, $t0, 1				#add offset to $t0 
	
	addi $t7, $t7, 1			# Increment loop counter
		
	move $t9, $zero
	addi $t9, $t9, 64
	bne $t7, $t9, MOVEBOARD			#loop until counter = 64
	
	subi $t0, $t0, 64			#reset $t0 to be the first index of the board
	
	# Print header	
	li $v0, 4 				#code 4 is to print a null-terminated string
	la $a0, HEADER				#print string HEADER
	syscall

	# Print horizontal lines	
	li $v0, 4 				#code 4 is to print a null-terminated string
	la $a0, HLINE				#print string HLINE 
	syscall
		
	# Loop through 8 times to print all rows of board
	# Create counter for outer loop (y)
	move $t1, $zero
FORROW:
	# Print vertical lines	
	li $v0, 4 				#code 4 is to print a null-terminated string
	la $a0, VLINE				#print string VLINE 
	syscall
	
	# Print the number for the current row (loop counter + 1)
	move $t2, $t1
	addi $t2, $t2, 1
	li $v0, 1 				#code 1 is to print an integer
	la $a0, ($t2)				#print the row number
	syscall
	
	# Print a space after the row number	
	li $v0, 4 				#code 4 is to print a null-terminated string
	la $a0, SPACE				#print string SPACE
	syscall
	
	# Loop through 8 times to print all columns in each row
	# Create counter for inner loop (x)
	move $t3, $zero
FORCOLUMN:
	# Calculate board index ((x*8)+y)
	# Store (x*8) in $t2
	move $t4, $t3
	move $t5, $zero
	addi $t5, $t5, 8			
	mult $t4, $t5				#multiply x by 8
	mflo $t4
	add $t4, $t4, $t1			#add y to x*8
	# Stored (x*8)+y in $t4
		
	# Print column separator line
	li $v0, 4 				#code 4 is to print a null-terminated string
	la $a0, COLSEP				#print string COLSEP
	syscall
	
	# Print correct board index (board is in $t0)
	# Noo need to multiply index by 4 because we are using a byte array
	# Add calculated offset (in $t4) to value of $t0 and store in $t5
	add $t5, $t4, $t0
	li $v0, 11 				#code 4 is to print a single character
	la $a0, ($t5)				#print correct index of board
	syscall
	
	# Print a space after the board value	
	li $v0, 4 				#code 4 is to print a null-terminated string
	la $a0, SPACE				#print string SPACE
	syscall
	
	# Increment inner loop counter x (in $t3)
	addi $t3, $t3, 1
	
	# Loop back to FORCOLUMN if not done 8 times yet
	move $t6, $zero
	addi $t6, $t6, 8
	bne $t3, $t6, FORCOLUMN
	
	# Now back in the outer loop (FORROW)
	
	# Print column separator line
	li $v0, 4 				#code 4 is to print a null-terminated string
	la $a0, COLSEP2				#print string COLSEP2
	syscall
	
	# Print vertical lines	
	li $v0, 4 				#code 4 is to print a null-terminated string
	la $a0, VLINE				#print string VLINE 
	syscall
	
	# Print horizontal lines	
	li $v0, 4 				#code 4 is to print a null-terminated string
	la $a0, HLINE				#print string HLINE 
	syscall
	
	# Increment outer loop counter y (in $t1)
	addi $t1, $t1, 1
	
	# Loop back to FORROW if not done 8 times yet
	move $t6, $zero
	addi $t6, $t6, 8
	bne $t1, $t6, FORROW	
	
	# If finished drawing board, return to calling address
	jr $ra			#return to caller address