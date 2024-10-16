.data
	string: .space 1024

.macro end
	li $v0, 10
	syscall
.end_macro

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

.macro print_success
	li $v0, 1
	li $a0, 1
	syscall
.end_macro

.macro print_fail
	li $v0, 1
	li $a0, 0
	syscall
.end_macro
	

.text
	jal Initial
	jal GetNum
	jal GetString
	jal Judge
	end
	
	Initial:
		li $s0, 0	# s0 = n
		li $s1, 0	# s1 = i
		li $s2, 0	# s2 = j
		li $s3, 0	# s3 = flag
		jr $ra
	
	GetNum:
		get_int($s0)
		jr $ra
	
	GetString:
		Begin_1:
			slt $t0, $s1, $s0
			beqz $t0, End_1
			get_char($t1)
			sb $t1, string($s1)
			addi $s1, $s1, 1
			j Begin_1
		End_1:
			li $s1, 0
			jr $ra
			
	Judge:
		move $s2, $s0
		addi $s2, $s2, -1	# j = n - 1	/ i = 0 
		Begin_2:
			slt $t0, $s1, $s2
			beqz $t0, End_2
			lb $t1, string($s1)
			lb $t2, string($s2)
			beq $t1, $t2, Equal
				li $s3, 1
			Equal:
			addi $s1, $s1, 1
			addi $s2, $s2, -1
			j Begin_2
		End_2:
			li $t0, 1
			beq $s3, $t0, NotHuiwen
				print_success
				jr $ra
			NotHuiwen:
				print_fail
				jr $ra
			