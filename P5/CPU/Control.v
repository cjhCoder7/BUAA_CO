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
    output [2:0] NPCop,
    output [1:0] WRsel,
    output EXTop,
    output [2:0] WDsel,
    output RFWr,
    output [1:0] Bsel,
    output [2:0] ALUop,
    output DMWr,
    input Zero,
    input [4:0] Mco,
    input Req,
    output En,
    output EXLClr,
    input Adel_IM,
    input Adel_DM,
    input Ades,
    input Ov,
    output reg [4:0] ExcCodeIn
    );

    wire ADD, SUB, ORI, BEQ, LW, SW, NOP, LUI, J, JAL, JR;

    wire SYSCALL, MFC0, MTC0, ERET;

    wire RI, Syscall;

    assign NOP = (Opcode == 6'b000000) & (Funct == 6'b000000);
    
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

    assign SYSCALL = (Opcode == 6'b000000) & (Funct == 6'b001100);
    assign MFC0 = (Opcode == 6'b010000) & (Mco == 5'b00000);
    assign MTC0 = (Opcode == 6'b010000) & (Mco == 5'b00100);
    assign ERET = (Opcode == 6'b010000) & (Funct == 6'b011000);

    assign EXTop = LW | SW;                       // 需要有符号扩展的指令
    assign RFWr  = (LW | LUI | ADD | SUB | ORI | JAL | MFC0) && (Req == 0);    // 需要向寄存器写入值的有这些指令, 确保异常时不会发生写入
    assign DMWr  = SW && (Req == 0); 
    // 选择哪个寄存器应该被写入，默认是rt；sub和add需要rd；jal需要31号寄存器
    assign WRsel = (SUB | ADD) ? 2'b01 :
                   (JAL) ? 2'b10 : 2'b00;
    // 选择写入寄存器的值，默认是000,即alu中算出来的值，001是内存里面的值，010是jal指令中PC+4的值, 011是CP0out出来的值
    assign WDsel = (LW) ? 3'b001 :
                   (JAL) ? 3'b010 : 
                   (MFC0) ? 3'b011 : 3'b000;
    // 选择进入alu中B端口的值，默认是寄存器堆中读出的第二个值，还可以是扩展后的Imm16
    assign Bsel  = (ORI | LW | SW | LUI) ? 2'b01 : 2'b00;
    // 选择NPC计算的模式，默认是PC + 4；001代表BEQ成功偏移；010代表j,jal偏移；011代表jr偏移; 100代表ERET返回正常程序的地址; 101代表跳入处理异常程序的片段
    assign NPCop = (BEQ & Zero) ? 3'b001 :
                   (J | JAL) ? 3'b010 :
                   (JR) ? 3'b011 : 
                   (ERET) ? 3'b100 : 
                   (Req) ? 3'b101 : 3'b000;
    // ALU计算模式，配合alu模块查看
    assign ALUop = (ADD | LW | SW) ? 3'b000 :
                   (SUB) ? 3'b001 :
                   (ORI) ? 3'b011 : 
                   (LUI) ? 3'b100 : 3'b101;
    // CP0写使能信号。
    assign En = (MTC0) ? 1 : 0;
    // EXLClr 用来复位 EXL。当EXLClr为1的时候，会让CP0中的EXL变为0
    assign EXLClr = (ERET) ? 1 : 0;

    assign RI = (ADD==0&&SUB==0&&JR==0&&ORI==0&&LW==0&&SW==0&&LUI==0&&BEQ==0&&JAL==0&&NOP==0&&SYSCALL==0&&MFC0==0&&MTC0==0&&ERET==0&&J==0);

    assign Syscall = (SYSCALL);

    always @(*) begin
        ExcCodeIn = 0;
        if (Adel_IM == 1) begin
            ExcCodeIn = 4;
        end
        else if (Ov == 1 && SW == 1'b1) begin
            ExcCodeIn = 5;
        end
        else if (Ov == 1 && LW == 1'b1) begin
            ExcCodeIn = 4;
        end
        else if (Ov == 1 && (ADD == 1'b1 | SUB == 1'b1)) begin
            ExcCodeIn = 12;
        end
        else if (RI == 1) begin
            ExcCodeIn = 10;
        end
        else if (Syscall == 1) begin
            ExcCodeIn = 8;
        end
        else if (Adel_DM == 1) begin
            ExcCodeIn = 4;
        end
        else if (Ades == 1) begin
            ExcCodeIn = 5;
        end
    end

endmodule
