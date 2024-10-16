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

.macro end
	li $v0, 10
	syscall
.end_macro

.text
	jal Initial
	jal GetNum
	jal GetMatrix1
	jal GetMatrix2
	jal BeforeOperate
	jal Operate
	end
	
	Initial:
		li $s0, 0	# s0 = m1
		li $s1, 0	# s1 = n1
		li $s2, 0	# s2 = m2
		li $s3, 0	# s3 = n2
		li $s4, 0	# s4 = i
		li $s5, 0	# s5 = j
		li $s6, 0	# s6 = m1 - m2 + 1
		li $s7, 0	# s7 = n1 - n2 + 1
		jr $ra
		
	GetNum:
		get_int($s0)
		get_int($s1)
		get_int($s2)
		get_int($s3)
		jr $ra
		
	GetMatrix1:
		Begin_1_1:
			slt $t0, $s4, $s0
			beqz $t0, End_1_1
			Begin_2_1:
				slt $t1, $s5, $s1
				beqz $t1, End_2_1
				get_int($t2)
				matrix_addr($t3, $s4, $s5, $s1)
				sw $t2, data1($t3)
				addi $s5, $s5, 1
				j Begin_2_1
			End_2_1:
				li $s5, 0
				addi $s4, $s4, 1
				j Begin_1_1
		End_1_1:
			li $s4, 0
			li $s5, 0
			jr $ra
			
	GetMatrix2:
		Begin_1_2:
			slt $t0, $s4, $s2
			beqz $t0, End_1_2
			Begin_2_2:
				slt $t1, $s5, $s3
				beqz $t1, End_2_2
				get_int($t2)
				matrix_addr($t3, $s4, $s5, $s3)
				sw $t2, data2($t3)
				addi $s5, $s5, 1
				j Begin_2_2
			End_2_2:
				li $s5, 0
				addi $s4, $s4, 1
				j Begin_1_2
		End_1_2:
			li $s4, 0
			li $s5, 0
			jr $ra
	
	BeforeOperate:
		subu $t0, $s0, $s2
		subu $t1, $s1, $s3
		addi $s6, $t0, 1
		addi $s7, $t1, 1
		jr $ra
		
	Operate:
		Begin_1_3:
			slt $t0, $s4, $s6
			beqz $t0, End_1_3
			Begin_2_3:
				slt $t1, $s5, $s7
				beqz $t1, End_2_3
				Begin_3_3:
					slt $t2, $t8, $s2
					beqz $t2, End_3_3
					Begin_4_3:
						slt $t3, $t9, $s3
						beqz $t3, End_4_3
						
						matrix_addr($t4, $t8, $t9, $s3)
						lw $k0, data2($t4)
						addu $t6, $s4, $t8
						addu $t7, $s5, $t9
						matrix_addr($t4, $t6, $t7, $s1)
						lw $k1, data1($t4)
						mult $k0, $k1
						mflo $t4
						addu $t5, $t5, $t4
						
						addi $t9, $t9, 1
						j Begin_4_3
					End_4_3:
						li $t9, 0
						addi $t8, $t8, 1
						j Begin_3_3
				End_3_3:
					li $t8, 0
					li $t9, 0
					addi $s5, $s5, 1
					print_int($t5)
					printSpace
					li $t5, 0
					j Begin_2_3
			End_2_3:
				li $t8, 0
				li $t9, 0
				li $s5, 0
				addi $s4, $s4, 1
				printEnter
				j Begin_1_3
		End_1_3:
			li $t8, 0
			li $t9, 0
			li $s5, 0
			li $s4, 0
			jr $ra