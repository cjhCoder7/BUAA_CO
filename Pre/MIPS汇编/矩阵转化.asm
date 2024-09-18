.data 
	matrix: .space 10000
	str_blank: .asciiz " "
	str_enter: .asciiz "\n"
	
.macro end
    li $v0, 10
    syscall
.end_macro

.macro printInt(%src)
    move	$a0, %src           # move value to $a0
    li      $v0, 1
    syscall
.end_macro

.macro printBlank
    la  $a0, str_blank
    li  $v0, 4
    syscall                     # 输出一个空格
.end_macro

.macro printEnter
    la $a0, str_enter
    li $v0, 4
    syscall                     # 输出一个回车
.end_macro

.macro getInt(%des)
    li      $v0, 5
    syscall
    move    %des, $v0
.end_macro

.macro getIndex(%ans, %i, %j)
    mult	%i, $s1			    # %i * $s1 = Hi and Lo registers
    mflo	%ans				# copy Lo to %ans
    add     %ans, %ans, %j      # %ans = %ans + %j
    sll     %ans, %ans, 2       # %ans = %ans * 4
.end_macro
    

.text
main:
jal Initial
jal PutValue
jal InputMatrix
jal OutputValue
end

Initial:
    li $s0, 0                   # s0 = n
    li $s1, 0                   # s1 = m
    li $s2, 0                   # s2 = i
    li $s3, 0                   # s3 = j
    li $s4, 0                   # s4 = i + 1
    li $s5, 0                   # s5 = j + 1
    li $t0, 0                   # t0 = tmp loop value
    li $t1, 0                   # t1 = tmp loop value
    li $t2, 0                   # t2 = tmp number
    li $t3, 0                   # t3 = tmp index
    li $t4, 0                   # t4 = tmp compare 0 value
    jr $ra

PutValue:
    getInt($s0)
    getInt($s1)
    jr $ra

InputMatrix:
    for_1_begin:
        slt $t0, $s2, $s0
        beq $t0, $0, for_1_end
        for_2_begin:
            slt $t1, $s3, $s1
            beq $t1, $0, for_2_end
            getInt($t2)
            getIndex($t3, $s2, $s3)
            sw $t2, matrix($t3)      # G[i][j] = t2 = inputNumber
            addi $s3, $s3, 1         # j++
            j for_2_begin
        for_2_end:
            li $s3, 0                # j = 0  重要：重置第二层循环的循环变量
            addi $s2, $s2, 1         # i++
            j for_1_begin
    for_1_end:
        li $s2, 0
        li $s3, 0
        li $t0, 0
        li $t1, 0
        li $t2, 0
        li $t3, 0
        jr $ra

OutputValue:
    addi $s2, $s0, -1                # i = n - 1
    addi $s3, $s1, -1                # j = m - 1
    for_3_begin:
        sge $t0, $s2, $0             # if i >= 0
        beq $t0, $0, for_3_end
        for_4_begin:
            sge $t1, $s3, $0         # if j >= 0
            beq $t1, $0, for_4_end
            getIndex($t3, $s2, $s3)
            lw $t2, matrix($t3)      # t2 = G[i][j]
            bne $t2, $0, Output      # if t2 != t0 then goto Output

            addi $s3, $s3, -1        # j--
            j for_4_begin

            Output:
                addi $s4, $s2, 1
                addi $s5, $s3, 1
                printInt($s4)
                printBlank
                printInt($s5)
                printBlank
                printInt($t2)
                printEnter

                addi $s3, $s3, -1    # j--
                j for_4_begin

        for_4_end:
            addi $s2, $s2, -1
            addi $s3, $s1, -1        # j = m - 1  重要：重置第二层循环的循环变量
            j for_3_begin
    for_3_end:
        li $s2, 0
        li $s3, 0
        li $s4, 0
        li $s5, 0
        li $t0, 0
        li $t1, 0
        li $t2, 0
        li $t3, 0
        jr $ra