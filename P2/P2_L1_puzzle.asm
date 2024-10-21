.data
	matrix: .word 1 : 81	# 9 * 9 matrix £ºall is 1 ; avoid exception 

.macro end
	li $v0, 10
	syscall
.end_macro

.macro get_int(%dst)
	li $v0, 5
	syscall
	move %dst, $v0
.end_macro

.macro print_int(%dst)
	li $v0, 1
	move $a0, %dst
	syscall
.end_macro

.macro push(%dst)
	addi $sp, $sp, -4
	sw %dst, 0($sp)
.end_macro

.macro pop(%dst)
	lw %dst, 0($sp)
	addi $sp, $sp, 4
.end_macro

.macro addr(%dst, %row, %col, %rank)
	multu %row, %rank
	mflo %dst
	addu %dst, %dst, %col
	sll %dst, %dst, 2
.end_macro

.text
jal Initial
jal InputMatrix
jal InputGoal
move $a1, $s6
move $a2, $s7
jal DFS
print_int($s5)
end

Initial:
	li $s0, 1
	li $s1, 0	# s1 = m
	li $s2, 0	# s2 = n
	li $s3, 0	# s3 = i 
	li $s4, 0	# s4 = j
	li $s5, 0	# s5 = number
	li $s6, 0	# s6 = startM
	li $s7, 0	# s7 = startN
	li $t8, 0	# t8 = endM
	li $t9, 0	# t9 = endN
	li $k0, 9
	jr $ra
	
InputMatrix:
	get_int($s1)
	get_int($s2)
	Begin_1_1:
		slt $t1, $s3, $s1
		beqz $t1, End_1_1
		Begin_2_1:
			slt $t2, $s4, $s2
			beqz $t2, End_2_1			
			addi $t3, $s3, 1
			addi $t4, $s4, 1
			addr($t0, $t3, $t4, $k0)
			get_int($t5)
			sw $t5, matrix($t0)
			addi $s4, $s4, 1
			j Begin_1_1
		End_2_1:
			li $s4, 0
			addi $s3, $s3, 1
			j Begin_1_1
	End_1_1:
		li $s4, 0
		li $s3, 0
		jr $ra
		
InputGoal:		
	get_int($s6)
	get_int($s7)
	get_int($t8)
	get_int($t9)
	jr $ra
	
DFS:
	push($ra)
	push($t1)
	push($t2)

	move $t1, $a1
	move $t2, $a2

	
	bne $t1, $t8, else
	bne $t2, $t9, else
	addi $s5, $s5, 1
	pop($t2)
	pop($t1)
	pop($ra)
	jr $ra
	
	else:
		addr($t3, $t1, $t2, $k0)
		sw $s0, matrix($t3)
		
		addi $t4, $t1, -1
		addr($t3, $t4, $t2, $k0)
		lw $t5, matrix($t3)
		bnez $t5, else1
		move $a1, $t4
		move $a2, $t2
		jal DFS
		else1:
			addi $t4, $t1, 1
			addr($t3, $t4, $t2, $k0)
			lw $t5, matrix($t3)
			bnez $t5, else2
			move $a1, $t4
			move $a2, $t2
			jal DFS
		else2:
			addi $t4, $t2, -1
			addr($t3, $t1, $t4, $k0)
			lw $t5, matrix($t3)
			bnez $t5, else3
			move $a1, $t1
			move $a2, $t4
			jal DFS
		else3:
			addi $t4, $t2, 1
			addr($t3, $t1, $t4, $k0)
			lw $t5, matrix($t3)
			bnez $t5, else4
			move $a1, $t1
			move $a2, $t4
			jal DFS
		else4:
			addr($t3, $t1, $t2, $k0)
			sw $zero, matrix($t3)
			pop($t2)
			pop($t1)
			pop($ra)
			jr $ra
			
				
					
						
							
								
									
										
											
	