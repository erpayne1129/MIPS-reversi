.data
	tilesToFlip: .space 32
	xdirection: .word 0, 1, 1, 1, 0, -1, -1, -1
	ydirection: .word 1, 1, 0, 1, -1, -1, 0, 1
	x: .word 4
	y: .word 4
	xstart: .word 0
	ystart: .word 0
	isOnBoard: .word 8
	board: .space 4, 4
	otherTile: .asciiz 0
	emptyspace: .asciiz " "

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
		la $a0, x
		la $a1, y
		jal getIndexLocation #line 63 : get player location
		lb $t7, $v0
		beq $t7, 1, andifboard 
		bne $t7, 1, exit1 #line 67
		andifboard:
		beq $t7, $s0, true
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
		beq $s0, $s1, whileT
		bne $s0, $s1, exit3
		
	whileT: #line 78
		sw $t5, xdirection #line 79
		sw $t6, ydirection
		sub $t1, $t1, $t5 #line 79 : x -= xdirection
		sub $t2, $t2, $t6 #y -= ydirection
			ifxstart: #line 81
			la $s2, xstart
			beq $t1, $t5, ifystart #if x == xstart
			ifystart: #line 81
			la $s3, ystart
			beq $t2, $s3, tilesToFlipx #if y == ystart
				#append tilesToFlip array x, y
				tilesToFlipx:
				sw $a0, x #set x for getIndex func
				sw $t1, tilesToFlip #store x into Flip array x
				tilesToFlipy:
				sw $a1, y #set y for getIndex func
				li $t6, 4 #set temp reg to move array y
				sw $t2, tilesToFlip($t6) #store y into Flip array y
				jal getIndexLocation
		
		bgt $t1, -1, whileT #loop back until -1 x
		bgt $t2, -1, whileT #loop back until -1 y

		exit3: #end of while loop
		jal tilesToFlip
		
		#help with line 83-88
		sw $t9, emptyspace #load emptyspace
		la $a0, $t9 #store emptyspace into board array 0
		la $a0, 4($t9) #store emptyspace into board array 1
		#sw $s2, $s0 #line 85 : store xstart into board array 0
		#sw $s3, 4($s0) #store ystart into board array 1
		
		beqz $v0, isInvalidMove 		
		#j isInvalidMove #used to return false : line 87
		move $v0, $ra
		jr $t8
exit:

#t7 is xy coordinate
#x, y in t1, t2
#jump to a0 and a1 for isOnBoard
#board in s0
#xstart in s2
#ystart in s3
#playersTile s1 = tile
#otherTile s5
#output tilesToFlip to v0


