.text
isOnBoard: #input: (x,y); checks if (x,y) is a tile on the 8x8 game board.
#Checks if x value is valid
blt $a0, 0,notOnBoard
bgt $a0, 8, notOnBoard

#checks if y value is valid
blt $a1, 0, notOnBoard
bgt $a1, 8, notOnBoard

#Return True (location is on board)
li $v0, 1
jr $ra

#Return False (location is not on board)
notOnBoard:
li $v0, 0
jr $ra