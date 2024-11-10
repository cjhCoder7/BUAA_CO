`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:14:19 10/29/2024 
// Design Name: 
// Module Name:    ALU 
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
`define ADD   3'b000
`define SUB   3'b001
`define AND   3'b010
`define OR    3'b011
`define LUI   3'b100
`define Other 3'b101

module ALU(
    input [31:0] A,
    input [31:0] B,
    output reg [31:0] C,
    input [2:0] ALUop,
    output Zero,
    output reg Ov     // 判断是否算数溢出 
    );

    reg [32:0] temp; // 33位扩展寄存器，用于溢出检测

    always @(*) begin
        Ov = 1'b0; // 默认没有溢出
        temp = 33'b0; // 初始化temp

        case (ALUop)
            `ADD: begin
                temp = {A[31], A} + {B[31], B}; // 符号扩展到33位进行加法
                if (temp[32] != temp[31]) begin // 溢出条件：最高位和第31位不同
                    Ov = 1'b1;
                    C = 32'h0; // 输出全0
                end else begin
                    C = temp[31:0]; // 取低32位作为结果
                end
            end
            `SUB: begin
                temp = {A[31], A} - {B[31], B}; // 符号扩展到33位进行减法
                if (temp[32] != temp[31]) begin // 溢出条件：最高位和第31位不同
                    Ov = 1'b1;
                    C = 32'h0; // 输出全0
                end else begin
                    C = temp[31:0]; // 取低32位作为结果                    
                end
            end
            `AND: begin
                C = A & B;
            end
            `OR: begin
                C = A | B;
            end
            `LUI: begin
                C = {B[15:0], 16'h0}; // 将 B 的低 16 位移动到高位
            end
            `Other: begin
                //根据需求扩展
            end
            default: begin
                C = 32'b0; // 默认输出为0
            end
        endcase
    end

    assign Zero = (A == B);

endmodule
