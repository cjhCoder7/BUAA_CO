.data
	str_enter:  .asciiz "\n"
	str_space:  .asciiz " "
	data1: .word 0 : 121       # storage for 11x11 matrix of words
	data2: .word 0 : 121       # storage for 11x11 matrix of words


.macro matrix_addr(%dst, %row, %column, %rank)
    # dts: the register to save the calculated address
    # row: the row that element is in
    # column: the column that element is in
    # rank: the number of columns in the matrix
    multu %row, %rank
    mflo %dst
    addu %dst, %dst, %column
    sll %dst, %dst, 2
.end_macro

.macro get_int(%dst)
	li $v0, 5
	syscall
	move %dst, $v0
.end_macro

.macro print_int(%des)
	li $v0, 1
	move $a0, %des
	syscall
.end_macro

.macro print_string(%des)
	li $v0, 4
	move $a0, %des
	syscall
.end_macro

.macro printBlank
    la  $a0, str_space
    li  $v0, 4
    syscall                     # 输出一个空格
.end_macro

.macro printEnter
    la $a0, str_enter
    li $v0, 4
    syscall                     # 输出一个回车
.end_macro

.macro end
	li $v0, 10
	syscall
.end_macro

.text
	jal Initial
	jal GetNum
	jal GetMatrix1
	jal GetMatrix2
	jal Operate
	end
	
	
	
	Initial:
		li $s0, 0	# s0 = row / col / n
		li $s1, 0	# s1 = i
		li $s2, 0	# s2 = j
		li $s3, 0	# s3 = k
		li $s4, 0	# s4 = tmpNum
		jr $ra
		
	GetNum:
		get_int($s0)
		jr $ra
		
	GetMatrix1:
		Begin_1_1:
			slt $t1, $s1, $s0
			beqz $t1, End_1_1
			Begin_2_1:
				slt $t2, $s2, $s0
				beqz $t2, End_2_1
				get_int($s4)
				matrix_addr($t0, $s1, $s2, $s0)
				sw $s4, data1($t0)
				addi $s2, $s2, 1	# j++
				j Begin_2_1
			End_2_1:
				li $s2, 0	# j = 0
				addi $s1, $s1, 1	# i++
				j Begin_1_1
		End_1_1:
			li $s1, 0
			li $s2, 0
			li $s4, 0
			jr $ra
			
	GetMatrix2:
		Begin_1_2:
			slt $t1, $s1, $s0
			beqz $t1, End_1_2
			Begin_2_2:
				slt $t2, $s2, $s0
				beqz $t2, End_2_2
				get_int($s4)
				matrix_addr($t0, $s1, $s2, $s0)
				sw $s4, data2($t0)
				addi $s2, $s2, 1	# j++
				j Begin_2_2
			End_2_2:
				li $s2, 0	# j = 0
				addi $s1, $s1, 1	# i++
				j Begin_1_2
		End_1_2:
			li $s1, 0
			li $s2, 0
			li $s4, 0
			jr $ra
	
	Operate:
		Begin_1_3:
			slt $t1, $s1, $s0
			beqz $t1, End_1_3
			Begin_2_3:
				slt $t2, $s2, $s0
				beqz $t2, End_2_3
					Begin_3_3:
						slt $t3, $s3, $s0
						beqz $t3, End_3_3
						
						matrix_addr($t0, $s1, $s3, $s0)
						lw $t4, data1($t0)
						matrix_addr($t0, $s3, $s2, $s0)
						lw $t5, data2($t0)
						mult $t4, $t5
						mflo $t6
						addu $s4, $s4, $t6
						
						addi $s3, $s3, 1
						j Begin_3_3
					End_3_3:
						li $s3, 0
						print_int($s4)
						printBlank
						li $s4, 0
						addi $s2, $s2, 1
						j Begin_2_3
			End_2_3:
				li $s2, 0
				printEnter
				addi $s1, $s1, 1
				j Begin_1_3
		End_1_3:
			li $s1, 0 
			li $s2, 0 
			li $s3, 0 
			jr $ra
		