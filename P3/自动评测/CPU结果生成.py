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
