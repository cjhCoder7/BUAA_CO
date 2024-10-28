## P3 课下感想☹️

### 设计草稿

#### NPC

端口定义

| 信号名      | 方向 | 描述                                         |
| ----------- | ---- | -------------------------------------------- |
| PC[31:0]    | I    | 当前指令的地址                               |
| Imm16[15:0] | I    | beq：16位偏移（`sw`或`lw`指令）              |
| Imm26[25:0] | I    | jal：26位偏移（`j`或`jal`指令）              |
| RA32[31:0]  | I    | jr：`$ra`寄存器保存的32位目标地址            |
| NPCop[1:0]  | I    | NPC计算模式的控制码                          |
| Zero        | I    | `rs`与`rt`相等的比较结果；1：相等；0：不相等 |
| NPC[31:0]   | O    | 下一条指令的地址                             |
| PC4[31:0]   | O    | 当前指令加4的地址                            |

**NPCop 选择器**

| NPCop | 功能                         |
| ----- | ---------------------------- |
| 00    | PC + 4                       |
| 01    | PC + 4 + sign_ext(Imm16 * 4) |
| 10    | PC + 4 + sign_ext(Imm26 * 4) |
| 11    | `$ra` 寄存器中存储的地址     |

NPC 里需要保证**偏移量都是 4 的倍数**，这样才可以直接忽略最低两位，取出相邻的指令

#### IM

端口定义

| 信号名            | 方向 | 描述       |
| ----------------- | ---- | ---------- |
| PC[31:0]          | I    | 指令的地址 |
| Instruction[31:0] | O    | 取出的指令 |

#### EXT

端口定义

| 信号名      | 方向 | 描述                   |
| ----------- | ---- | ---------------------- |
| Imm16[15:0] | I    | 16位数                 |
| EXTop       | I    | 0：零扩展；1：符号扩展 |
| 32bit[31:0] | O    | 扩展后的32位数         |

#### RF

端口定义

| 信号名    | 方向 | 描述                                                         |
| --------- | ---- | ------------------------------------------------------------ |
| A1[4:0]   | I    | 5位寄存器地址输入信号，将其储存的数据读出到 RD1（`rs`里面的值） |
| A2[4:0]   | I    | 5位寄存器地址输入信号，将其储存的数据读出到 RD2（`rt`里面的值） |
| A3[4:0]   | I    | 5位寄存器地址输入信号，将其作为写入数据的目标寄存器（`rd`寄存器） |
| WD[31:0]  | I    | 要写入的32位数据                                             |
| RFWr      | I    | 寄存器堆写使能信号：1：写使能信号有效；0：写使能信号无效     |
| Clk       | I    | 时钟信号                                                     |
| Reset     | I    | 异步复位信号：1：复位信号有效；0：复位信号无效               |
| RD1[31:0] | O    | 输出A1指定的寄存器中的32位数据                               |
| RD2[31:0] | O    | 输出A2指定的寄存器中的32位数据                               |

#### ALU

端口定义

| 信号名        | 方向 | 描述               |
| ------------- | ---- | ------------------ |
| A[31:0]       | I    | 32位输入A          |
| B[31:0]       | I    | 32位输入B          |
| C[31:0]       | I    | 32位输出C          |
| ALUop[3:0]    | I    | 运算控制信号       |
| Zero          | O    | A = B：1；否则为0  |
| Less          | O    | A < B：1；否则为0  |
| Less or Equal | O    | A <= B：1；否则为0 |

**ALUop说明**

| 信号值  | 功能                               |
| ------- | ---------------------------------- |
| 4'b0000 | A + B                              |
| 4'b0001 | A - B                              |
| 4'b0010 | A \| B                             |
| 4'b0011 | A & B                              |
| 4'b0100 | lui 指令                           |
| 4‘b0101 | 算数左移/逻辑左移                  |
| 4'b0110 | 算数右移（左边添加的数和符号有关） |
| 4'b0111 | 逻辑右移（左边统一添0）            |

#### DM

端口定义

| 信号名   | 方向 | 描述                                                 |
| -------- | ---- | ---------------------------------------------------- |
| A[31:0]  | I    | 内存中的地址信号                                     |
| WD[31:0] | I    | 在内存写使能信号有效时，写入内存地址的数据           |
| DMWr     | I    | 内存写使能信号：1：写使能信号有效；0：写使能信号无效 |
| Clk      | I    | 时钟信号                                             |
| Reset    | I    | 异步复位信号：1：复位信号有效；0：复位信号无效       |
| RD[31:0] | O    | 输出内存中对应地址的数据                             |

需要注意的是，当只是实现 `lw` 和 `sw` 这两条指令的时候，需要保证**内存的地址是 4 的倍数**，所以简单一点就可以直接忽略地址中最低的两位。

但是如果是实现 `lb` `sb` `lh` `sh` 这些指令的时候是不需要保证内存是 4 的倍数，所以就需要加入一个指令选择信号，来确定该如何在RAM里面存储

#### Control

| 端口  | add  | sub  | ori  | lw   | sw   | beq  | lui  | nop  |
| ----- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- |
| NPCop | 00   | 00   | 00   | 00   | 00   | 01   | 00   | xx   |
| WRsel | 1    | 1    | 0    | 0    | x    | x    | 0    | x    |
| EXTop | x    | x    | 0    | 1    | 1    | x    | 0    | x    |
| WDsel | 00   | 00   | 00   | 01   | xx   | xx   | 00   | xx   |
| RFWr  | 1    | 1    | 1    | 1    | 0    | 0    | 1    | x    |
| Bsel  | 0    | 0    | 1    | 1    | 1    | 0    | 1    | x    |
| ALUop | 0000 | 0001 | 0010 | 0000 | 0000 | 0001 | 0100 | xxxx |
| DMWr  | 0    | 0    | 0    | 0    | 1    | 0    | 0    | x    |

### 测试方案

对于logisim实现的单周期CPU测试，我采用的主要还是自动化测试的方式，然后和其他同学进行对拍验证

#### MIPS指令数据的构造

使用python完成，大致思路是使用<u>两个数组来模拟寄存器堆和内存堆</u>，确保在随机生成指令的时候不会出现溢出等错误。

需要注意的是在生成`lw`和`sw`指令的时候，**需要保证内存的地址一定要是 4 的倍数**，否则会造成无法对齐的错误！🥰🥰

另外，寄存器最好开始也要用 `ori` 指令进行<u>初始化</u>，不然可能会产生一直在 0 与 0 之间加减的无效指令

> 对于边界测试点，我的做法是设计概率，一半的概率设计生成中间的随机数，另一半的概率设计生成靠近边界的随机数

```python
grf = [0] * 32  # 模拟寄存器文件
dm = [0] * 10000  # 模拟内存
generated_labels = set()
```

```python
def random_reg() -> int:
    """生成0到31之间的随机寄存器编号"""
    return random.randint(0, 31)


def random_imm() -> int:
    """生成0到65535之间的无符号16位随机立即数"""
    boundary_values = [0, 1, 2, 65534, 65533, 65535]
    if random.random() < 0.5:  # 50% 概率生成边界值
        return random.choice(boundary_values)
    return random.randint(0, 65535)
```

```python
def add() -> str:
    """生成add指令"""
    rs, rt, rd = random_reg(), random_reg(), random_reg()
    result = grf[rt] + grf[rd]
    if -2147483648 <= result <= 2147483647:
        grf[rs] = result
        return f"add ${rs},${rt},${rd}"
    else:
        grf[rt] = 0 | 1000
        grf[rd] = 0 | 1000
        return f"ori ${rt},$0,1000\n" f"ori ${rd},$0,1000"


def sub() -> str:
    """生成sub指令"""
    rs, rt, rd = random_reg(), random_reg(), random_reg()
    result = grf[rt] - grf[rd]
    if -2147483648 <= result <= 2147483647:
        grf[rs] = result
        return f"sub ${rs},${rt},${rd}"
    else:
        grf[rt] = 0 | 1000
        grf[rd] = 0 | 1000
        return f"ori ${rt},$0,1000\n" f"ori ${rd},$0,1000"


def ori() -> str:
    """生成ori指令"""
    rs, rt, imm = random_reg(), random_reg(), random_imm()
    grf[rs] = grf[rt] | imm
    return f"ori ${rs},${rt},{imm}"


def nop() -> str:
    """生成nop指令"""
    return "nop"


def lui() -> str:
    """生成lui指令"""
    rt = random_reg()
    imm = random_imm()
    grf[rt] = imm << 16
    return f"lui ${rt},{imm}"


def lw() -> str:
    """生成 lw 指令，确保地址是4的倍数"""
    rt, base = random_reg(), random_reg()
    offset = random.randint(0, 750) * 4

    legal_base = random.randint(0, (3000 - offset) // 4) * 4
    grf[base] = legal_base

    grf[rt] = dm[grf[base] + offset]
    return f"ori ${base}, $0, {legal_base}\n" f"lw ${rt}, {offset}(${base})"


def sw() -> str:
    """生成 sw 指令，确保地址是4的倍数"""
    rt, base = random_reg(), random_reg()
    offset = random.randint(0, 750) * 4

    legal_base = random.randint(0, (3000 - offset) // 4) * 4
    grf[base] = legal_base

    dm[grf[base] + offset] = grf[rt]
    return f"ori ${base}, $0, {legal_base}\n" f"sw ${rt}, {offset}(${base})"


def beq() -> List[Union[str, List[str]]]:
    """生成beq指令及后续指令"""
    rs, rt = random_reg(), random_reg()
    label = "".join(random.choices(string.ascii_letters, k=5))
    while label in generated_labels:
        label = "".join(random.choices(string.ascii_letters, k=5))
    generated_labels.add(label)

    beq_string = [f"beq ${rs},${rt},{label}"]
    beq_string.extend(
        [
            add(),
            sub(),
            ori(),
            sw(),
            lw(),
            lui(),
            f"{label}:",
            add(),
            sub(),
            ori(),
            sw(),
            lw(),
            lui(),
        ]
    )
    return beq_string
```

```python
def initial_reg() -> List[str]:
    """初始化所有寄存器不为0"""
    init_string = [f"ori ${i},$0,{random_imm()}" for i in range(1, 32)]
    return init_string


def generate_test_cases(num_cases: int = 10) -> List[Union[str, List[str]]]:
    """生成测试用例"""
    instructions = [add, sub, ori, lw, sw, lui, nop, beq]
    test_cases = initial_reg()

    for _ in tqdm.tqdm(range(num_cases), desc="Generating test cases"):
        instruction = random.choice(instructions)
        if instruction == beq:
            test_cases.extend(instruction())
        else:
            test_cases.append(instruction())

    return test_cases
```

#### 调用logisim进行测试

在将随机生成的MIPS指令放入MARS生成16进制编码后，便可以调用logisim生成CPU运行的结果了

```python
import os
import re


print("添加指令至单周期cpu中" + "\n")
content = open("test.txt").read()
mymem = open("单周期cpu.circ", encoding="utf-8").read()
mymem = re.sub(
    r"addr/data: 12 32([\s\S]*?)</a>", "addr/data: 12 32\n" + content + "</a>", mymem
)
with open("单周期cpu镜像.circ", "w", encoding="utf-8") as file:
    file.write(mymem)


print("运行单周期cpu中" + "\n")
command = "java -jar logisim-generic-2.7.1.jar 单周期cpu镜像.circ -tty table > 单周期cpu结果.txt"
os.system(command)
```

<u>注意这里的正则表达式匹配的端口位数需要根据你自己的CPU进行调整</u>

运行一段时间后可以手动中断程序（如果没加入 `halt` 的话）

### 思考题

1. 上面我们介绍了通过 FSM 理解单周期 CPU 的基本方法。请大家指出单周期 CPU 所用到的模块中，哪些发挥状态存储功能，哪些发挥状态转移功能。

   > 状态存储模块：RF、PC、DM、IM
   >
   > 状态转移模块：ALU、Control、NPC、EXT

2. 现在我们的模块中 IM 使用 ROM， DM 使用 RAM， GRF 使用 Register，这种做法合理吗？ 请给出分析，若有改进意见也请一并给出。

   > 我认为对于这样的简单实现是合理的，GRF需要高速读取，使用寄存器，但是，和现代计算机不同的是，现在计算机CPU中IM和DM都是共用的一个RAM，**因为有动态加载和修改程序的指令的需求**，所以单单只使用ROM是不合适的

3. 在上述提示的模块之外，你是否在实际实现时设计了其他的模块？如果是的话，请给出介绍和设计的思路。

   > 无

4. 事实上，实现 nop 空指令，我们并不需要将它加入控制信号真值表，为什么？

   > 因为 `nop` 指令本质上对应的是 `sll $0, $0, 0`，对于寄存器堆和内存堆中的任何值都不会发生变化，所以可以忽略

5. 阅读 Pre 的 “MIPS 指令集及汇编语言” 一节中给出的测试样例，评价其强度（可从各个指令的覆盖情况，单一指令各种行为的覆盖情况等方面分析），并指出具体的不足之处。

   > 没有对边界情况进行详细的考虑：65533,65534,65535−2,−1,0,1,2
   >
   > `sw` 和 `lw` 没有考虑offset为负数的情况
   >
   > 特别的，对于 `lw` 指令，可注意测试目标寄存器是 `$0` 的情况
   >
   > `beq` 指令不仅要测试跳转到后面标签的情况，还要测试跳转到前面和跳转到当前指令的情况

## P3 课上测试感想😇

这次的 P3 感觉上是要比前两年要难的，特别是对于指令内部的要求是很多的。

**经验吸取**：在课下进行搭建的时候，对于每一个 `sel` 信号，我们可以不止定义成一位的，可以定义成三位或者是四位，来应对扩展指令的要求，避免在课上要进行多余的修改。（<u>鄙人就是犯了这个错误，浪费了很多时间</u>）

这次回答的问题有一些蹊跷，感觉在课上根本就没有学过啊 😨😨😨

> P3 搭建的单周期CPU采用的是哈佛架构还是冯洛依曼架构？
>
> 答案：哈佛架构：IM 和 DM分开的架构

纪念 P3 通过！

![](image/1.png)