import os
import random
import string
import tqdm
from typing import List, Union


grf = [0] * 32  # 模拟寄存器文件
dm = [0] * 10000  # 模拟内存
generated_labels = set()


# 随机生成寄存器和立即数
def random_reg() -> int:
    """生成0到31之间的随机寄存器编号"""
    return random.randint(0, 31)


def random_imm() -> int:
    """生成0到65535之间的无符号16位随机立即数"""
    boundary_values = [0, 1, 2, 65534, 65533, 65535]
    if random.random() < 0.5:  # 50% 概率生成边界值
        return random.choice(boundary_values)
    return random.randint(0, 65535)


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


def print_test(test_cases: List[Union[str, List[str]]]) -> None:
    """打印测试用例"""
    print(".text")
    for case in test_cases:
        if isinstance(case, list):
            for sub_case in case:
                print(sub_case)
        else:
            print(case)


def to_file(
    test_cases: List[Union[str, List[str]]], filename: str = "mips1.asm"
) -> None:
    """将测试用例输出到指定的.asm文件"""
    output_path = os.path.join(os.path.dirname(__file__), filename)
    with open(output_path, "w") as file:
        file.write(".text\n")
        for case in test_cases:
            if isinstance(case, list):
                for sub_case in case:
                    file.write(sub_case + "\n")
            else:
                file.write(case + "\n")


if __name__ == "__main__":
    random.seed(2)
    test_cases = generate_test_cases(200)
    to_file(test_cases)
