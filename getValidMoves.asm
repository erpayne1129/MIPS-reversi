.data
validMoves: .word 0:64
.text

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
li $t4, 0 #counter for y loop

#Loop for iterating through all possible x values
xLoop:
beq $t3, 8, xEnd # if t3 == 8 we are done
addi $t3, $t3, 1 # add 1 to t1

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