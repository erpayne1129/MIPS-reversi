.data
welcomeMessage: .asciiz "\nWelcome to Reversi!\n"
mainBoard: .byte 'E':64	#creates an empty board of 64 characters (to be used and modified)
whoGoesFirst: .asciiz "\nThe X will go first.\n"
gameOver: .asciiz "\nGAME OVER!\n"
xWins: .asciiz "\nX wins!\n"
oWins: .asciiz "\nO wins!\n"


exampleBoard: .byte	' ':64	#creates an empty board of 64 characters (to be used and modified)
BOARDTODRAW: .byte 'E':64	#creates an empty board of 64 characters (to be used and modified)
HEADER:	.asciiz "  | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |\n"	#label for each column
HLINE:	.asciiz "  +---+---+---+---+---+---+---+---+\n"	#horizontal line for board
VLINE:	.asciiz "  |   |   |   |   |   |   |   |   |\n"	#vertical line for board
COLSEP:	.asciiz "| "	#column seperator for formatting
COLSEP2:.asciiz "|\n"	#column seperator for formatting


X:	.asciiz "X"		#represents a piece belonging to player X
O:	.asciiz "O"		#represents a piece belonging to player O
SPACE:	.asciiz " "		#space used for blanking out board
BOARDTORESET: .byte 'E':64	#creates an empty board of 64 characters (to be used and modified)


message: .asciiz "Enter your move, or type -1 to end the game.\n"
message1: .asciiz "That is not a valid move. Type the x digit (1-8), then the y digit (1-8)."


xScoreText: .asciiz "X has "
oScoreText: .asciiz "O has "
tilesText: .asciiz " tiles\n"

tilesToFlip: .word 0:64
xDirection: .word 0,1,1,1,0,-1,-1,-1
yDirection: .word 1,1,0,-1,-1,-1,0,1

validMoves: .word 0:64

.text

main:
#Print welcome message
la $a0, welcomeMessage
li $v0, 4
syscall


#Reset the board and game.
la $s0, mainBoard

move $a0, $s0
jal RESETBOARD
move $s0, $v0

li $s1, 0x58
li $s2, 0x4f

la $a0, whoGoesFirst
li $v0, 4
syscall

mainLoop:

#Draw the current board
move $a0, $s0
jal DRAWBOARD

#Print the points
move $a0, $s0
jal showPoints

#Get the player's move
move $a0, $s0
move $a1, $s1
jal getPlayerMove

#Make the move
move $a0, $s0
move $a1, $s1
move $a2, $v0
move $a3, $v1
jal makeMove

#get all valid moves for other player
move $a0, $s0
move $a1, $s2
jal getValidMoves
lb $t0, ($v0)
beq $t0, -1, breakMain

#####End Plyaer 1##############
############################################################
####Start Player 2#############

#Draw the current board
move $a0, $s0
jal DRAWBOARD

#Print the points
move $a0, $s0
jal showPoints

#Get player 2's move
move $a0, $s0
move $a1, $s2
jal getPlayerMove

#Make the move
move $a0, $s0
move $a1, $s2
move $a2, $v0
move $a3, $v1
jal makeMove

#get all valid moves for other player
move $a0, $s0
move $a1, $s1
jal getValidMoves
lb $t0, ($v0)
beq $t0, -1, breakMain

j mainLoop#Loop back for next turn

breakMain:

#Draw the current board
move $a0, $s0
jal DRAWBOARD

#Print GAME OVER
la $a0, gameOver
li $v0, 4
syscall

#Show final score
move $a0, $s0
jal showPoints

#get X and O scores
move $a0, $s0
jal getScoreOfBoard

#Branch if X lost
bgt $v1, $v0, xLoses
#x won :)
la $a0, xWins
li $v0, 4
syscall

#exit program
li $v0, 10
syscall


xLoses: #x lost :(
la $a0, oWins
li $v0, 4
syscall

#exit program
li $v0, 10
syscall


############################################################################
########Subroutines#########################################################
############################################################################

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
	jr $ra			#return to caller address

###########################################################################

RESETBOARD:
	#la $a0, BOARDTORESET		#load example board (comment out in final version)
	
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
	jr $ra			#return to caller address
	
######################################################################
	
getPlayerMove:
move $s1,$a0
move $s7, $ra

whileTrue:

li $v0,4
la $a0, message
syscall

li $v0, 5
syscall
move $t0, $v0
beq $t0, -1, ExitProgram

li $v0, 5
syscall
move $t1,$v0

sub $t0, $t0, 1
sub $t1, $t1, 1


move $a0,$s1
move $a2,$t0
move $a3,$t1
jal isValidMove 
beq $v0,0, else

move $v0, $t0
move $v1, $t1
move $ra, $s7
jr $ra
else:
li $v0,4
la $a0, message1
syscall
j whileTrue


ExitProgram:
li $v0, 10
syscall

###########################################################

makeMove:
addi $sp, $sp, -32
sw $s0, ($sp)
sw $s1, 4($sp)
sw $s2, 8($sp)
sw $s3, 12($sp)
sw $s3, 16($sp)
sw $s4, 20($sp)
sw $s5, 24($sp)
sw $s6, 28($sp)
sw $s7, 32($sp)


move $s6, $a1
move $s7, $ra
move $s5, $a0

jal isValidMove
move $t0, $v0

lb $t1, ($t0)
beq $t1, -1, invalidMove

li $s1, 0 #loop iterator

makeMoveLoop:
sll $t2, $s1, 2
add $t3, $t0, $t2
lw $t4, ($t3)

beq $t4, -1, moveFinished

sb $s6, ($t4)

addi $s1, $s1, 1
j makeMoveLoop


invalidMove:
li $v0, 0
move $ra, $s7

lw $s0, ($sp)
lw $s1, 4($sp)
lw $s2, 8($sp)
lw $s3, 12($sp)
lw $s3, 16($sp)
lw $s4, 20($sp)
lw $s5, 24($sp)
lw $s6, 28($sp)
lw $s7, 32($sp)
addi $sp, $sp, 32

jr $ra

moveFinished:
li $v0, 1
move $ra, $s7

lw $s0, ($sp)
lw $s1, 4($sp)
lw $s2, 8($sp)
lw $s3, 12($sp)
lw $s3, 16($sp)
lw $s4, 20($sp)
lw $s5, 24($sp)
lw $s6, 28($sp)
lw $s7, 32($sp)
addi $sp, $sp, 32

jr $ra

####################################################
showPoints:
addi $sp, $sp, -32
sw $s0, ($sp)
sw $s1, 4($sp)
sw $s2, 8($sp)
sw $s3, 12($sp)
sw $s3, 16($sp)
sw $s4, 20($sp)
sw $s5, 24($sp)
sw $s6, 28($sp)
sw $s7, 32($sp)

move $s7, $ra
#Get the current scores for X, O
jal getScoreOfBoard
move $t0, $v0
move $t1, $v1

#Print xScoreText
la $a0, xScoreText
li $v0, 4
syscall

#Print number of X tiles 
li $v0, 1
move $a0, $t0
syscall

#Suffix
la $a0, tilesText
li $v0, 4
syscall

#Print yScoreText
la $a0, oScoreText
li $v0, 4
syscall

#Print number of Y tiles
li $v0, 1
move $a0, $t1
syscall

la $a0, tilesText
li $v0, 4
syscall

move $ra, $s7

lw $s0, ($sp)
lw $s1, 4($sp)
lw $s2, 8($sp)
lw $s3, 12($sp)
lw $s3, 16($sp)
lw $s4, 20($sp)
lw $s5, 24($sp)
lw $s6, 28($sp)
lw $s7, 32($sp)
addi $sp, $sp, 32

jr $ra

############################################

getIndexLocation: #Take an x,y coordinate and translate it into a single-array index location
mulu $t0, $a1, 8
add $t0, $t0, $a0
move $v0, $t0
jr $ra

#################################################
isValidMove:
#Save entire contents of $s0-$s7
addi $sp, $sp, -32
sw $s0, ($sp)
sw $s1, 4($sp)
sw $s2, 8($sp)
sw $s3, 12($sp)
sw $s3, 16($sp)
sw $s4, 20($sp)
sw $s5, 24($sp)
sw $s6, 28($sp)
sw $s7, 32($sp)

#Move arguments to temporaries (so that  original arguments are not overwritten)
move $s0, $a0
move $s1, $a1
move $s2, $a2
move $s3, $a3
move $s4, $ra #save 

#Get the Board index location with the given X and Y coordinates
move $a0, $s2
move $a1, $s3
jal getIndexLocation
move $t0, $v0
move $ra, $s4

add $t0, $t0, $s0

#Load value of Board(x,y)
lb $t1, ($t0)

bne $t1, 0x20, isInvalidMove #check if Board(x,y)=" "
move $a0, $s2 #move x to argument list
move $a1, $s3 #move y to argument list
jal isOnBoard #see if (x,y) is on Board
move $ra, $s4 #restore jump address
bne $v0, 1, isInvalidMove #if not on board, return false value

sb $s1, ($t0) #temporarily set the tile on the board.


beq $s1, 0x58, playerIsX #Check whether player is O or X
li $s5, 0x58 #if player is O set OtherTile ($s5) to X
j flippingTiles #jump to continue code
playerIsX:
li $s5, 0x4f #set other tile to O

flippingTiles:
la $s6, tilesToFlip #Load tilesToFlip base address
la $t3, xDirection #xDirection base address
la $t4, yDirection #xDirection base address
li $t0, 0 #DirectionLoop counter

li $t8, 0 #tilesToFlip position counter

directionLoop:

bgt $t0, 7, toFlipFinished

move $t1, $s2 #xStart
move $t2, $s3 #yStart


add $t5, $t0, $t3 #Calculate offset for xDirection
lw $t5, ($t5) #xDirection

add $t6, $t0, $t4 #Caluclate offset for yDirection
lw $t6, ($t6) #yDirection

add $t1, $t1, $t5 #x += xDirection
add $t2, $t2, $t6 #y += yDirection

#Check if x,y is on the board
move $a0, $t1
move $a1, $t2
jal isOnBoard

bne $v0, 0, continueFlipLoop #If the x,y is not on the board, branch to continue loop
addi $t0, $t0, 1 #increment DirectionLoop counter
j directionLoop

continueFlipLoop:

jal getIndexLocation #find the offset for main array
add $t7, $v0, $s0
lb $t7, ($t7) #t7 = mainBoard location in question

bne $t7, $s5, continueFlipLoop2
add $t1, $t1, $t5 #x += xDirection
add $t2, $t2, $t6 #y += yDirection

#Check if x,y is on the board
move $a0, $t1
move $a1, $t2
jal isOnBoard

beq $v0, 0, continueFlipLoop2 #if tile is not on board, break out of while loop

continueFlipLoop2:

#Check if x,y is on the board
move $a0, $t1
move $a1, $t2
jal isOnBoard

bne $v0, 0, continueFlipLoop3 #If the x,y is not on the board, branch to continue loop
addi $t0, $t0, 1 #increment DirectionLoop counter
j directionLoop

continueFlipLoop3:

move $a0, $t1
move $a1, $t2

jal getIndexLocation #find the offset for main array
add $t7, $v0, $s0
lb $t7, ($t7) #t7 = mainBoard location in question

beq $t7, $s1, continueFlipLoop4 #If tile is not found, continue for loop
addi $t0, $t0, 1 #increment DirectionLoop counter
j directionLoop

continueFlipLoop4:

sub $t1, $t1, $t5 #x -= xDirection
sub $t2, $t2, $t6 #y -+ yDirection

bne $t1, $s2, continueFlipLoop5
bne $t2, $s3, continueFlipLoop5
addi $t0, $t0, 1 #increment DirectionLoop counter
j directionLoop

continueFlipLoop5:

move $a0, $t1
move $a0, $t2

jal getIndexLocation #find the offset for main array
add $t7, $v0, $s0

#store address of tile to flip in tilesToFlip array
sll $t9, $t8, 2
add $t9, $t9, $s6
sw $t7, ($t9)

addi $t8, $t8, 1

j continueFlipLoop4


toFlipFinished:

sll $t8, $t8, 2
add $t9, $s6, $t8
li $t7, -1
sw $t7, ($t9)

lw $t7, ($s6)
beq $t7, -1, isInvalidMove
move $ra, $s4
move $v0, $s6
jr $ra

isInvalidMove: #move is invalid, so output false and jump return
#Restore contents of $s0-$s7
move $ra, $s4
lw $s0, ($sp)
lw $s1, 4($sp)
lw $s2, 8($sp)
lw $s3, 12($sp)
lw $s3, 16($sp)
lw $s4, 20($sp)
lw $s5, 24($sp)
lw $s6, 28($sp)
lw $s7, 32($sp)
addi $sp, $sp, 32
li $v0, 0

jr $ra
##################################################################################
getValidMoves:
#Store contents of $s0-$s7 to stack
addi $sp, $sp, -32
sw $s0, ($sp)
sw $s1, 4($sp)
sw $s2, 8($sp)
sw $s3, 12($sp)
sw $s3, 16($sp)
sw $s4, 20($sp)
sw $s5, 24($sp)
sw $s6, 28($sp)
sw $s7, 32($sp)

move $s0, $a0
move $s1, $a1
move $s2, $ra
la $t0, validMoves
li $t1, 0 #Initialize a counter (for adding null terminator)

li $t2, 8 #constant for loop
li $t3, 0 #counter for x loop

#Loop for iterating through all possible x values
xLoop:
beq $t3, 8, xEnd # if t3 == 8 we are done
addi $t3, $t3, 1 # add 1 to t1
li $t4, 0

#Loop for iterating through all possible y values
yLoop:
beq $t4, 8, yEnd # if t4 == 8 we are done

#set arguments and call move validation
move $a0, $s0
move $a1, $a1
move $a2, $t3
move $a3, $t4
jal isValidMove


lb $t5, ($v0)
beq $t5, -1, spaceIsInvalid #Check if move was invalid
sll $t6, $t1, 2 #multiply position counter by 4
add $t6, $t6, $t0 #calculate offset

#convert (x,y) to single-array index
move $a0, $t3
move $a1, $t4
jal getIndexLocation
sb $v0, ($t6) #store single-array index location in array
addi $t1, $t1, 1 #increment position counter

spaceIsInvalid:
addi $t4, $t4, 1 #increment loop counter
j yLoop #return to loop
yEnd: #y loop has finished

j xLoop #return to x loop

#ends entire loop
xEnd:
#set null terminator of -1 in validMoves array
sll $t6, $t1, 2
add $t6, $t6, $t0
li $t7, -1
sb $t7 ($t6)

#Restore return address and set output validMoves root
move $ra, $s2
move $v0, $t0
#Restore contents of $s0-$s7
lw $s0, ($sp)
lw $s1, 4($sp)
lw $s2, 8($sp)
lw $s3, 12($sp)
lw $s3, 16($sp)
lw $s4, 20($sp)
lw $s5, 24($sp)
lw $s6, 28($sp)
lw $s7, 32($sp)
addi $sp, $sp, 32

jr $ra

##########################################################################
getScoreOfBoard:
move $s3, $a0
li $t1, 0 #initialize x
li $t3, 8 #max iterations
li $s0, 0 #X score
li $s1, 0 #O score
move $t7, $ra

xScore:
beq $t1, $t3, scoreFinished
li $t2, 0 #initialize y

yScore:
beq $t2, $t3, xScoreIncrement
move $a0, $t1
move $a1, $t2
jal getIndexLocation
add $t4, $v0, $s3
lb $t4, ($t4)

beq $t4, 0x58, tileIsX
beq $t4, 0x20, tileIsSpace
addi $s1, $s1, 1
addi $t2, $t2, 1
j yScore

tileIsX:
addi $s0, $s0, 1
addi $t2, $t2, 1
j yScore

tileIsSpace:
addi $t2, $t2, 1
j yScore

xScoreIncrement:
addi $t1, $t1, 1
j xScore

scoreFinished:
move $v0, $s0
move $v1, $s1
move $ra, $t7
jr $ra
#########################################################################
isOnBoard: #input: (x,y); checks if (x,y) is a tile on the 8x8 game board.
#Checks if x value is valid
blt $a0, 0,notOnBoard
bgt $a0, 7, notOnBoard

#checks if y value is valid
blt $a1, 0, notOnBoard
bgt $a1, 7, notOnBoard

#Return True (location is on board)
li $v0, 1
jr $ra

#Return False (location is not on board)
notOnBoard:
li $v0, 0
jr $ra
