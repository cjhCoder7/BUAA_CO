.data
	matrix: .space  256         # G[8][8]
	book: .space 32             # book[8]
	str_enter: .asciiz "\n"

.macro getMatrixIndex(%ans, %i, %j)
    sll %ans, %i, 3             # %ans = %i * 8
    add %ans, %ans, %j          # %ans = %ans + %j
    sll %ans, %ans, 2           # %ans = %ans * 4
.end_macro

.macro getBookIndex(%ans, %i)
	sll %ans, %i, 2             # %ans = %ans * 4
.end_macro

.macro end
    li $v0, 10
    syscall
.end_macro

.macro printInt(%src)
    move	$a0, %src           # move value to $a0
    li      $v0, 1
    syscall
.end_macro

.macro getInt(%des)
    li      $v0, 5
    syscall
    move    %des, $v0
.end_macro

.macro push(%src)
    addi    $sp, $sp, -4
    sw      %src, 0($sp)
.end_macro

.macro pop(%des)
    lw      %des, 0($sp)
    addi    $sp, $sp, 4
.end_macro	

.text
main:
jal Initial
jal PutValue
jal InputMatrix

li $t3, 0
move $a0, $t3
jal DFS
printInt($t1)
end

Initial:
	li $s0, 0                        # s0 = n
	li $s1, 0                        # s1 = m
	li $t0, 0                        # t0 = i
	li $t1, 0                        # t1 = ans
	li $t2, 0                        # t2 = flag
	li $t3, 0                        # t3 = x
	li $t4, 0                        # t4 = y
	li $t5, 0                        # formal parameter
	li $t7, 1                        # consistant value 1
	jr $ra
	
PutValue:
	getInt($s0)
	getInt($s1)
	jr $ra
	
InputMatrix:
	li $t0, 0                        # int i = 0
	li $t6, 1                        # 1
	Begin:
		slt $t5, $t0, $s1
		beq $t5, $0, End
		getInt($t3)
		getInt($t4)
		addi $t3, $t3, -1            # x - 1
		addi $t4, $t4, -1            # y - 1
		getMatrixIndex($t5,$t3,$t4)
		sw $t6, matrix($t5)
		getMatrixIndex($t5,$t4,$t3)
		sw $t6, matrix($t5)
		addi $t0, $t0, 1             # i++
		j Begin		
	End:
		li $t6, 0
		li $t5, 0
		li $t0, 0
		jr $ra
		
DFS:
	push($ra)
	push($t5)
	move $t5, $a0                    # t5 formal parameter a0 actual parameter
	getBookIndex($t6, $t5)           # t6 temp index
	sw $t7, book($t6)                # book[x] = 1
	
	li $t2, 1                        # flag = 1
	li $t0, 0                        # i = 0
	
	for_1_begin:
		slt $s7, $t0, $s0
		beq $s7, $0, for_1_end
		getBookIndex($t6, $t0)       # t6 temp index
		lw $s6, book($t6)            # s6 book[i]
		and $t2, $t2, $s6            # flag &= book[i]
		addi $t0, $t0, 1             # i++
		j for_1_begin
	for_1_end:
		li $t0, 0                    # make i = 0 again
		beq $t2, $0, for_2_begin     # flag = 0 is true?
		getMatrixIndex($t6, $t5, $0)
		lw $s5, matrix($t6)          # s5 G[x][0]
		beq $s5, $0, for_2_begin     # G[x][0] = 0 is true?
		li $t1, 1                    # t1 = ans = 1
		pop($t5)
		pop($ra)
		jr $ra		                 # return
	for_2_begin:
		slt $s7, $t0, $s0
		beq $s7, $0, for_2_end
		getBookIndex($t6, $t0)
		lw $s6, book($t6)            # s6 book[i]
		bne $s6, $0, for_2_begin_tmp # !book[i] = 0 is true?
		getMatrixIndex($t6, $t5, $t0)
		lw $s5, matrix($t6)          # s5 G[x][i]
		beq $s5, $0, for_2_begin_tmp # G[x][i] = 0 is true?
		move $a0, $t0                # manage loog i (t0)
		push($t0)
		jal DFS
		pop($t0)
		addi $t0, $t0, 1             # i++
		j for_2_begin
		
	for_2_begin_tmp:
		addi $t0, $t0, 1             # i++
		j for_2_begin
		
	for_2_end:
		li $t0, 0
		getBookIndex($t6, $t5)       # t6 temp index
		sw $0, book($t6)             # book[x] = 0
		pop($t5)
		pop($ra)
		jr $ra