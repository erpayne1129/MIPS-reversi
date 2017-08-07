.data 
message: .asciiz "Enter your move, or type -1 to end the game.\n"
message1: .asciiz "That is not a valid move. Type the x digit (1-8), then the y digit (1-8)."
.text 
main:
jal GetPlayerMove



GetPlayerMove:
move $s1,$a0

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

sub $t0, $t0, -1
sub $t1, $t1, -1


move $a0,$s1
move $a2,$t0
move $a3,$t1
jal isValidMove 
beq $v0,-1, else
move $v0, $t0
move $v1, $t1
jr $ra
else:
li $v0,4
la $a0, message1
syscall
j whileTrue




ExitProgram:
li $v0, 10
syscall
