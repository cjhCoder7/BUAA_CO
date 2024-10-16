## P1 课下感想☹️

### 声明数组

```assembly
data: .word 0 : 256       # storage for 16x16 matrix of words
```

### 读取一个整数

```assembly
.macro get_int(%dst)
	li $v0, 5
	syscall
	move %dst, $v0
.end_macro
```

### 打印一个整数

```assembly
.macro print_int(%des)
	li $v0, 1
	move $a0, %des
	syscall
.end_macro
```

### 读取字符并存储

```assembly
.data
	string: .space 1024

.macro get_char(%dst)
	li $v0, 12
	syscall
	move %dst, $v0
.end_macro

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
```

### 打印字符串

```assembly
.macro print_string(%des)
	li $v0, 4
	move $a0, %des
	syscall
.end_macro
```

### 打印空格和回车

```assembly
.data
	str_enter:  .asciiz "\n"
	str_space:  .asciiz " "
	
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
```

### 获取二维数组地址

```assembly
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
```

### 压栈入栈

```assembly
.macro push(%dst)
	addi $sp, $sp, -4
	sw %dst, 0($sp)
.end_macro
	
.macro pop(%dst)	
	lw %dst, 0($sp)
	addi $sp, $sp, 4
.end_macro
```

### 结束程序

```assembly
.macro end
	li $v0, 10
	syscall
.end_macro
```

### 易错点

在注意压栈入栈的时候，有些隐性的参数也是要进行保护的，比如循环变量 `i`

```c
// 全排列生成
#include <stdio.h>
#include <stdlib.h>

int symbol[7], array[7];
int n;

void FullArray(int index) {
    int i;
    if (index >= n) {
        for (i = 0; i < n; i++) {
            printf("%d ", array[i]);
        }
        printf("\n");
        return;
    }
    for (i = 0; i < n; i++) {
        if (symbol[i] == 0) {
            array[index] = i + 1;
            symbol[i] = 1;
            FullArray(index + 1);
            symbol[i] = 0;
        }
    }
}

int main() {
    int i;
    scanf("%d", &n);
    FullArray(0);
    return 0;
}
```

这种题在写函数的时候，除了要保护`index`以外，还需要保护`i`

```assembly
FullArray:
	push($ra)
	push($t0)
	push($t5)
	move $t0, $a0	# a0 = index
	move $t5, $s1	# s1 = i = 0
	
	# ……
	
	li $t5, 0
	pop($t5)
	pop($t0)
	pop($ra)
	jr $ra
```

## P1 课上测试感想😇