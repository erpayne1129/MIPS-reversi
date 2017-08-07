.text
isValidMove:
#Move arguments to temporaries (so that  original arguments are not overwritten)
move $s0, $a0
move $s1, $a1
move $s2, $a2
move $s3, $a3
move $s4, $ra #save 

#Get the Board index location with the given X and Y coordinates
jal getIndexLocation
move $t0, $a0
move $ra, $s4

#Load value of Board(x,y)
lb $t1, ($t0)

bne $t1, 0x20, isInvalidMove #check if Board(x,y)=" "
move $a0, $s2 #move x to argument list
move $a1, $s3 #move y to argument list
jal isOnBoard #see if (x,y) is on Board
move $ra, $s4 #restore jump address
bne $v0, 1, isInvalidMove #if not on board, return false value

sb $s1, ($t1) #temporarily set the tile on the board.


beq $s1, 0x58, playerIsX #Check whether player is O or X
li $s5, 0x58 #if player is O set OtherTile ($s5) to X
j flippingTiles #jump to continue code
playerIsX:
li $s5, 0x4f #set other tile to O

flippingTiles:

isInvalidMove: #move is invalid, so output false and jump return
li $v0, 0
jr $ra