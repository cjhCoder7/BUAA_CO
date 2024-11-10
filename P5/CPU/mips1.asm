# �������ȴ���������
.text
    # �������
    lui $t0, 0x7fff
    lui $t1, 0x7fff
    add $t2, $t0, $t1
end:
    beq $0, $0, end
    nop

.ktext 0x4180 
# �쳣��������ı���λ��
_entry:
    # ����������
    j _save_context
    nop

_main_handler:
    # ȡ�� ExcCode
    mfc0 $k0, $13
    ori $k1, $0, 0x7c
    and $k0, $k0, $k1

    # ������жϣ�ֱ�ӻָ�������
    beq $k0, $0, _restore_context
    nop

    # �� EPC + 4���������쳣�ķ�������������ǰָ��
    mfc0 $k0, $14
    add $k0, $k0, 4
    mtc0 $k0, $14
    j _restore_context
    nop

_exception_return:
    eret

_save_context:
    ori $k0, $0, 0x1000     # ��ջ����һ��ռ䱣���ֳ�
    add $k0, $k0, -256
    sw $sp, 116($k0)        # ���ȱ���ջָ��
    move $sp, $k0

    # ���α���ͨ�üĴ�����ע��Ҫ���� $sp����HI �� LO
    sw $1, 4($sp)
    sw $2, 8($sp)
    # ......
    sw $31, 124($sp)
    mfhi $k0
    mflo $k1
    sw $k0, 128($sp)
    sw $k1, 132($sp)

    j _main_handler
    nop

_restore_context:
    # ���λָ�ͨ�üĴ�����ע��Ҫ���� $sp���� HI �� LO
    lw $1, 4($sp)
    lw $2, 8($sp)
    lw $31, 124($sp)
    lw $k0, 128($sp)
    lw $k1, 132($sp)
    mthi $k0
    mtlo $k1

    # ���ָ�ջָ��
    lw $sp, 116($sp)

    j _exception_return
    nop