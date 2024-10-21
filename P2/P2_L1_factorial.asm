.data 
	out: .word 1 : 1000	# storage the out array
	
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
li $t0, 2
slt $t1, $s0, $t0
beqz $t1, op
li $t2, 1
print_int($t2)
end

op:
	jal Process
	jal Output
	end

Initial:
	li $s0, 0	# s0 = n
	li $s1, 1	# s1 = high
	li $s2, 0	# s2 = mult carry
	li $s3, 0	# s3 = i
	li $s4, 0	# s4 = j
	jr $ra
	
Process:
	li $s3, 2	# i start with 2: 1 * 2 * 3 * бнбн
	Begin1:
		sle $t0, $s3, $s0	# i(start 2) <= n
		beqz $t0, End1
		
		li $s2, 0
		Begin2:
			slt $t1, $s4, $s1
			beqz $t1, End2
			addr($t2, $s4)
			lw $t3, out($t2)	# t3 = out[j]
			multu $s3, $t3	# i * out[j]
			mflo $t3
			addu $t3, $t3, $s2 	# i * out[j] + up
			li $t4, 10
			divu $t3, $t4
			mflo $s2	# up = out[j] / 10
			mfhi $t3
			sw $t3, out($t2)	# out[j] = out[j] % 10
			addi $s4, $s4, 1
			j Begin2
		End2:
			li $s4, 0
			j Begin3
		
		Begin3:
			beqz $s2, End3
			addr($t2, $s1)
			li $t4, 10
			divu $s2, $t4
			mfhi $t3
			mflo $s2			# up = up / 10
			sw $t3, out($t2)	# out[high] = up % 10
			addi $s1, $s1, 1	# high++
			j Begin3
		End3:
			li $s2, 0
			addi $s3, $s3, 1
			j Begin1
	End1:
		li $s3, 0
		jr $ra

Output:
	addi $s1, $s1, -1
	Begin4:
		sge $t1, $s1, $zero
		beqz $t1, End4
		addr($t2, $s1)
		lw $t3, out($t2)
		print_int($t3)
		addi $s1, $s1, -1
		j Begin4
	End4:
		jr $ra
		
			 
	