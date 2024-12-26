`timescale 1ns / 1ps

module Control(
    input [5:0] Opcode,
    input [5:0] Funct,

    input cmpSuc,    // 用来判断是否需要更改写入的寄存器，也就是WRsel，一般用于链接

    output [2:0] NPCop,
    output [2:0] WRsel,
    output EXTop,
    output [2:0] WDsel,
    output RFWr,
    output [2:0] Bsel,
    output [2:0] ALUop,
    output DMWr,
    output [2:0] D_Tuse_rs,
    output [2:0] D_Tuse_rt,
    output [1:0] CMPop
    );

    wire ADD, SUB, ORI, BEQ, LW, SW, NOP, LUI, J, JAL, JR;
    
    assign ADD = (Opcode == 6'b000000) & (Funct == 6'b100000);
    assign SUB = (Opcode == 6'b000000) & (Funct == 6'b100010);
    assign JR  = (Opcode == 6'b000000) & (Funct == 6'b001000);

    assign ORI = (Opcode == 6'b001101);
    assign LW  = (Opcode == 6'b100011);
    assign SW  = (Opcode == 6'b101011);
    assign LUI = (Opcode == 6'b001111);
    assign BEQ = (Opcode == 6'b000100);

    assign J   = (Opcode == 6'b000010);
    assign JAL = (Opcode == 6'b000011);

    assign EXTop = LW | SW;                       // 需要有符号扩展的指令
    assign RFWr  = LW | LUI | ADD | SUB | ORI | JAL;    // 需要向寄存器写入值的有这些指令
    assign DMWr  = SW; 
    // 选择哪个寄存器应该被写入，默认是rt；sub和add需要rd；jal需要31号寄存器
    assign WRsel = (SUB | ADD) ? 3'b001 :
                   (JAL) ? 3'b010 : 3'b000;
    // 选择写入寄存器的值，默认是00,即alu中算出来的值，01是内存里面的值，10是jal指令中PC+4的值
    assign WDsel = (LW) ? 3'b001 :
                   (JAL) ? 3'b010 : 3'b000;
    // 选择进入alu中B端口的值，默认是寄存器堆中读出的第二个值，还可以是扩展后的Imm16
    assign Bsel  = (ORI | LW | SW | LUI) ? 3'b001 : 3'b000;
    // 选择NPC计算的模式，默认是PC + 4；01代表BEQ成功偏移；10代表j,jal偏移；11代表jr偏移
    assign NPCop = (BEQ) ? 3'b001 :
                   (J | JAL) ? 3'b010 :
                   (JR) ? 3'b011 : 3'b000;
    // ALU计算模式，配合alu模块查看
    assign ALUop = (ADD | LW | SW) ? 3'b000 :
                   (SUB) ? 3'b001 :
                   (ORI) ? 3'b011 : 
                   (LUI) ? 3'b100 : 3'b101;
    // 比较操作选择，00代表相等的比较，01为其他的比较方式
    assign CMPop = (BEQ) ? 2'b00 : 2'b01;

    assign D_Tuse_rs = (ADD | SUB | ORI | LW | SW | LUI) ? 3'b001 :
                       (BEQ | JR | JAL) ? 3'b000 : 3'b011;

    assign D_Tuse_rt = (ADD | SUB) ? 3'b001 :
                       (SW) ? 3'b010 :
                       (BEQ) ? 3'b000 : 3'b011;
endmodule