	.data
X:	.asciiz "X"		#represents a piece belonging to player X
O:	.asciiz "O"		#represents a piece belonging to player O
SPACE:	.asciiz " "		#space used for blanking out board
BOARDTORESET: .byte 'E':64	#creates an empty board of 64 characters (to be used and modified)
#exampleBoard: .byte	' ':64	#creates an empty board of 64 characters (to be used and modified)
BOARDTODRAW: .byte 'E':64	#creates an empty board of 64 characters (to be used and modified)
HEADER:	.asciiz "  | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |\n"	#label for each column
HLINE:	.asciiz "  +---+---+---+---+---+---+---+---+\n"	#horizontal line for board
VLINE:	.asciiz "  |   |   |   |   |   |   |   |   |\n"	#vertical line for board
COLSEP:	.asciiz "| "	#column seperator for formatting
COLSEP2:.asciiz "|\n"	#column seperator for formatting
	.text



RESETBOARD:
	la $a0, BOARDTORESET		#load example board (comment out in final version)
	
	# Blank out the board received as argument ($a0)
	# except for the original starting position	
	la $t0, BOARDTORESET			#hold a temporary board to hold the argument board
	
	# Loop through 64 times to load all indices of board
	# Create counter for loop
	move $t7, $zero
MOVEBOARDRESET:	
	# Move the full board from $a0
	# Iterate through indixes		
	lb $t8, ($a0)				#load the next byte from the board
	sb $t8, ($t0)				#set i($t0) to value of i($a0) (the board)
	
	add $a0, $a0, 1				#add offset to board address 
	add $t0, $t0, 1				#add offset to $t0 
	
	addi $t7, $t7, 1			# Increment loop counter
		
	li $t9, 64
	bne $t7, $t9, MOVEBOARDRESET			#loop until counter = 64
	
	subi $t0, $t0, 64			#reset $t0 to be the first index of the board
	
	
	# Loop through 8 times to clear all rows of board
	# Create counter for outer loop (y)
	move $t1, $zero
FORROWRESET:
	# Loop through 8 times to clear all columns in each row
	# Create counter for inner loop (x)
	move $t2, $zero
FORCOLUMNRESET:
	# Calculate board index ((x*8)+y)
	# Store (x*8) in $t3
	move $t3, $t2
	move $t4, $zero
	addi $t4, $t4, 8			
	mult $t3, $t4				#multiply x by 8
	mflo $t3
	add $t3, $t3, $t1			#add y to x*8
	# Stored (x*8)+y in $t3
		
	# Set correct board index = " " (board is in $t0)
	# No need to multiply index by 4 because we are using a byte array
	# Add calculated offset (in $t3) to value of $t0 and store in $t4
	add $t4, $t3, $t0
	lb $t5, SPACE
	sb $t5, ($t4)
	
	# Increment inner loop counter x (in $t2)
	addi $t2, $t2, 1
	# Loop back to FORCOLUMN if not done 8 times yet
	li $t6, 8
	bne $t2, $t6, FORCOLUMNRESET
	
	# Now back in the outer loop (FORROW)
	
	# Increment outer loop counter y (in $t1)
	addi $t1, $t1, 1
	# Loop back to FORROW if not done 8 times yet
	li $t6, 8
	bne $t1, $t6, FORROWRESET
	
	# If finished clearing board, set initial starting position
	# board[3][3] = 'X'	[3][3] = 3(8)+3 = [27]
	lb $t5, X
	sb $t5, 27($t0) 
	# board[3][4] = 'O'	[3][4] = 3(8)+4 = [28]
	lb $t5, O
	sb $t5, 28($t0) 
	# board[4][3] = 'O'	[4][3] = 4(8)+3 = [35]
	lb $t5, O
	sb $t5, 35($t0) 
	# board[4][4] = 'X'	[4][4] = 4(8)+4 = [36]
	lb $t5, X
	sb $t5, 36($t0) 
	
	la $v0, ($t0)		#return the cleared board	
	#jr $ra			#return to caller address


##END OF RESET
	
	#load return value into $a0
	la $a0, ($v0)

##NOW DRAWING BOARD


DRAWBOARD:
	#la $a0, exampleBoard			#load example board (comment out in final version)
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
		
	li $t9, 64
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
	addi $t2, $t1, 1			#add 1 to value of y
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
	# Calculate board index ((y*8)+x)
	# Store (y*8) in $t2
	move $t4, $t1				#store y into $t4
	li $t5, 8			
	mult $t4, $t5				#multiply y by 8
	mflo $t4
	add $t4, $t4, $t3			#add x to y*8
	# Stored (y*8)+x in $t4
		
	# Print column separator line
	li $v0, 4 				#code 4 is to print a null-terminated string
	la $a0, COLSEP				#print string COLSEP
	syscall
	
	# Print correct board index (board is in $t0)
	# No need to multiply index by 4 because we are using a byte array
	# Add calculated offset (in $t4) to value of $t0 and store in $t5
	add $t5, $t4, $t0
	li $v0, 11 				#code 4 is to print a single character
	lb $a0, ($t5)				#print correct index of board
	syscall
	
	# Print a space after the board value	
	li $v0, 4 				#code 4 is to print a null-terminated string
	la $a0, SPACE				#print string SPACE
	syscall
	
	# Increment inner loop counter x (in $t3)
	addi $t3, $t3, 1
	
	# Loop back to FORCOLUMN if not done 8 times yet
	li $t6, 8
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
	li $t6, 8
	bne $t1, $t6, FORROW	
	
	# If finished drawing board, return to calling address
	#jr $ra			#return to caller address









