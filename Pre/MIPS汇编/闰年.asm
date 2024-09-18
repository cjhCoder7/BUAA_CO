.data
    year: .word 0

.macro end
    li $v0, 10
    syscall
.end_macro

.macro getInt(%des)
    li      $v0, 5
    syscall
    move    %des, $v0
.end_macro

.macro printInt(%src)
    move	$a0, %src           # move value to $a0
    li      $v0, 1
    syscall
.end_macro

.text
main:
jal Initial
jal PutValue
jal Output
end


Initial:
    li $a0, 0                  # a0 = address
    li $s0, 0                  # s0 = year
    li $s1, 1                  # s1 = 1
    li $t0, 0                  # t0 = 除 4 的余数
    li $t1, 0                  # t1 = 除 100 的余数
    li $t2, 0                  # t2 = 除 400 的余数
    li $t3, 4                  # t3 = 4
    li $t4, 100                # t4 = 100
    li $t5, 400                # t5 = 400
    jr $ra
    
PutValue:
    getInt($s0)
    la $a0, year               # 加载 year 标签的地址到 $a0 寄存器
    sw $s0, 0($a0)             # 将 $s0 的值存储到 $a0 寄存器指向的地址
    jr $ra    

Output:
    lw $s0, year
    div $s0, $t3               # year / 4
    mfhi $t0
    bnez $t0, notLeapYear
    div $s0, $t4               # year / 100
    mfhi $t1
    bnez $t1, leapYear
    div $s0, $t5               # year / 400
    mfhi $t2
    bnez $t2, notLeapYear
    j leapYear

    leapYear:
        printInt($s1)
        jr $ra

    notLeapYear:
        printInt($0)
        jr $ra