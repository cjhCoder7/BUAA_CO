.data
	array: .word 0 : 26
	character: .space 26
	str_enter:  .asciiz "\n"
	str_space:  .asciiz " "
	
.macro get_int(%dst)
	li $v0, 5
	syscall
	move %dst, $v0
.end_macro

.macro get_char(%dst)
	li $v0, 12
	syscall
	move %dst, $v0
.end_macro

.macro print_int(%dst)
	li $v0, 1
	move $a0, %dst
	syscall
.end_macro

.macro print_char(%dst)
	li $v0, 11
	move $a0, %dst
	syscall
.end_macro

.macro printSpace
    la  $a0, str_space
    li  $v0, 4
    syscall                     # 输出一个空格
.end_macro

.macro printEnter
    la $a0, str_enter
    li $v0, 4
    syscall                     # 输出一个回车
.end_macro

.macro addr(%dst, %src)
	sll %dst, %src, 2
.end_macro

.macro end
	li $v0, 10
	syscall
.end_macro

.text
jal Initial
get_int($s0)
jal Process
jal Output
end

Initial:
	li $s0, 0	# s0 = n
	li $s1, 0	# s1 = i
	li $s2, 0	# s2 = num
	li $s3, 0	# s3 = j
	li $s4, 0	# s4 = flag
	jr $ra
	
Process:
	Begin1:
		slt $t0, $s1, $s0
		beqz $t0, End1
		
		get_char($t1)
		get_char($t2)
		Begin2:
			slt $t3, $s3, $s2
			beqz $t3, End2
			lb $t4, character($s3)
			beq $t4, $t1, equal
				addi $s3, $s3, 1
				j Begin2
			equal:
				addr($t6, $s3)
				lw $t5, array($t6)
				addi $t5, $t5, 1
				sw $t5, array($t6)
				li $s4, 1
				addi $s3, $s3, 1
				j Begin2
		End2:
			li $s3, 0
			beqz $s4, new
				li $s4, 0
				addi $s1, $s1, 1
				j Begin1
			new:
				sb $t1, character($s2)
				addr($t6, $s2)
				li $t5, 1
				sw $t5, array($t6)
				addi $s2, $s2, 1
				li $s4, 0
				addi $s1, $s1, 1
				j Begin1	
	End1:
		li $s1, 0
		jr $ra
Output:
	Begin3:
		slt $t0, $s1, $s2
		beqz $t0, End3
		
		addr($t2, $s1)
		lw $t3, array($t2)
		lb $t4, character($s1)
		print_char($t4)
		printSpace
		print_int($t3)
		printEnter
		
		addi $s1, $s1, 1
		j Begin3
	End3:
		jr $ra
		
		
		
		