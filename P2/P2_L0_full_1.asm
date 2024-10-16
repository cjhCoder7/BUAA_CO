.data
	str_enter:  .asciiz "\n"
	str_space:  .asciiz " "
	symbol: .word 0 : 7
	array: .word 0 : 7

.macro end
	li $v0, 10
	syscall
.end_macro

.macro addr(%dst, %src)
	sll %dst, %src, 2
.end_macro

.macro print_enter
	la $a0, str_enter
	li $v0, 4
	syscall
.end_macro

.macro print_space
	la $a0, str_space
	li $v0, 4
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
	
.text
jal Initial	
jal GetNum
li $a0, 0
jal FullArray	
end
	
Initial:
	li $s0, 0	# s0 = n
	li $s1, 0	# s1 = i
	jr $ra
	
GetNum:
	get_int($s0)
	jr $ra	
	
FullArray:
	push($ra)
	push($t0)
	push($t5)
	
	move $t0, $a0
	move $t5, $s1	
	sge $t1, $t0, $s0 
	beqz $t1, Begin_2
	
	Begin_1:
		slt $t1, $t5, $s0
		beqz $t1, End_1
		addr($t2, $t5)
		lw $t2, array($t2)
		print_int($t2)
		print_space
		addi $t5, $t5, 1
		j Begin_1
	End_1:
		li $t5, 0
		print_enter
		pop($t5)
		pop($t0)
		pop($ra)
		jr $ra
	
	Begin_2:
		slt $t1, $t5, $s0
		beqz $t1, End_2
		
		addr($t2, $t5)
		lw $t2, symbol($t2)
		seq $t3, $t2, $zero
		beqz $t3, NotIf
		
		addr($t2, $t0)
		addi $t3, $t5, 1
		sw $t3, array($t2)
		
		li $t3, 1
		addr($t2, $t5)
		sw $t3, symbol($t2)
		
		addi $a0, $t0, 1
		jal FullArray
		
		addr($t2, $t5)
		sw $zero, symbol($t2)
		
		NotIf:
			addi $t5, $t5, 1
			j Begin_2
	End_2:
		li $t5, 0
		pop($t5)
		pop($t0)
		pop($ra)
		jr $ra
	
	