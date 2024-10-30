`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:20:33 10/29/2024 
// Design Name: 
// Module Name:    Control 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Control(
    input [5:0] Opcode,
    input [5:0] Funct,
    output [1:0] NPCop,
    output [1:0] WRsel,
    output EXTop,
    output [1:0] WDsel,
    output RFWr,
    output [1:0] Bsel,
    output [2:0] ALUop,
    output DMWr,
    input Zero
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
    assign WRsel = (SUB | ADD) ? 2'b01 :
                   (JAL) ? 2'b10 : 2'b00;
    // 选择写入寄存器的值，默认是00,即alu中算出来的值，01是内存里面的值，10是jal指令中PC+4的值
    assign WDsel = (LW) ? 2'b01 :
                   (JAL) ? 2'b10 : 2'b00;
    // 选择进入alu中B端口的值，默认是寄存器堆中读出的第二个值，还可以是扩展后的Imm16
    assign Bsel  = (ORI | LW | SW | LUI) ? 2'b01 : 2'b00;
    // 选择NPC计算的模式，默认是PC + 4；01代表BEQ成功偏移；10代表j,jal偏移；11代表jr偏移
    assign NPCop = (BEQ & Zero) ? 2'b01 :
                   (J | JAL) ? 2'b10 :
                   (JR) ? 2'b11 : 2'b00;
    // ALU计算模式，配合alu模块查看
    assign ALUop = (ADD | LW | SW) ? 3'b000 :
                   (SUB) ? 3'b001 :
                   (ORI) ? 3'b011 : 
                   (LUI) ? 3'b100 : 3'b101;
endmodule
