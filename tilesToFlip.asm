.data
	tilesToFlip: .space 40
	xdirection: .word 0
	ydirection: .word 0
	x: .word 4
	y: .word 4
	xstart: .word 0
	ystart: .word 0
	isOnBoard: .word 8
	board: .space 4, 4
	otherTile: .asciiz 0

.text

# Not sure what this for loop is doing, help with arrays
forXYdirection:	# line 59
	la $t1, x #line 60
	la $t2, y
	sw $t1, xstart #line 60
	sw $t2, ystart
	la $t1, xdirection($t1) #line 61
	la $t2, ydirection($t2)
	 
	ifisOnBoard: #line 63
		beq $s0, $s5, true #line 63
		bne $s0, $s5, exit1 #line 67
		true:	la $t1, xdirection($t1)
			la $t2, ydirection($t2)
			j exit1
		exit1: #line 68
	beq $s5, $s0, while #line 69: board, otherTile
	bne $s5, $s0, exit2
	while:	#line 69
		la $t1, xdirection($t1) #line 70
		la $t2, ydirection($t2)
		beq $s5, $s0, while
		bne $s5, $s0, exit2
	exit2:	#line 73
	ifboardXY: #line 76
		beq $s0, $s4, whileT
		bne $s0, $s4, exit3
	whileT: #line 78
		sw $a2, xdirection #line 79
		sw $a3, ydirection
		la $t1, $t1, $a2 #line 79
		la $t2, $t2, $a3
		bgt $s0, -1, whileT
		ble $s0, -1, exit3
			ifxstart: #line 81
			la $t3, xstart
			beq $t1, $t3, ifystart
			ifystart: #line 81
			la $t4, ystart
			beq $t2, $t4, exit3
		exit3:
		#help with line 83-88
			
		j isInvalidMove #used to return false : line 87
exit:

#x, y in t1, t2
#jump to a0 and a1 for isOnBoard
#board in s0
#xstart in s2
#ystart in s3
#playersTile s4 = tile
#otherTile s5
#output tilesToFlip to v0


