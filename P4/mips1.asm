lui $1, 13042
ori $1, $1, 104
sub $0, $0, $1
ori $2, $0, 29562
ori $3, $0, 3
lui $1, 65535
ori $1, $1, 65534
add $4, $0, $1
lui $1, 16671
ori $1, $1, 6678
sub $5, $0, $1
ori $6, $0, 1879
ori $7, $0, 56357
lui $1, 22433
ori $1, $1, 7060
sub $8, $0, $1
lui $1, 32768
ori $1, $1, 0
add $9, $0, $1
lui $1, 29706
ori $1, $1, 54326
sub $10, $0, $1
ori $11, $0, 23913
lui $1, 18970
ori $1, $1, 44413
add $12, $0, $1
ori $13, $0, 46651
lui $1, 32768
ori $1, $1, 1
add $14, $0, $1
lui $1, 32768
ori $1, $1, 1
add $15, $0, $1
lui $1, 32768
ori $1, $1, 2
add $16, $0, $1
lui $1, 65535
ori $1, $1, 65533
add $17, $0, $1
lui $1, 15930
ori $1, $1, 4520
add $18, $0, $1
lui $1, 32767
ori $1, $1, 11365
add $19, $0, $1
ori $20, $0, 46506
lui $1, 65535
ori $1, $1, 65532
add $21, $0, $1
lui $1, 32456
ori $1, $1, 64532
sub $22, $0, $1
ori $23, $0, 53781
lui $1, 6559
ori $1, $1, 16965
add $24, $0, $1
lui $1, 32768
ori $1, $1, 2
add $25, $0, $1
ori $30, $0, 2
lui $1, 20829
ori $1, $1, 59906
add $31, $0, $1
beq $0, $0, start
beqBack_0:
add $4, $14, $23
lw $4, 12232($0)
beq $0, $0, beqRet_0
beqBack_1:
lui $4, 58872
beq $0, $0, beqRet_1
beqBack_2:
nop
add $22, $8, $7
beq $0, $0, beqRet_2
beqBack_3:
nop
lui $17, 57110
beq $0, $0, beqRet_3
jalBack_0:
jr $ra
jalBack_1:
jr $ra
jalBack_2:
lui $5, 13294
jr $ra
start:
sw $11, 7748($0)
nop
ori $9, $14, 33082
lw $6, 10232($0)
lw $21, 2972($0)
jal jalBack_0
nop
add $9, $6, $21
beqRet_0:
beqRet_1:
beqRet_2:
beqRet_3:
