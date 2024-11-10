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

    always @(*) begin
        Ov = 1'b0;
        case (ALUop)
            `ADD: begin
                C = A + B;
                if ((A[31] == B[31]) && (C[31] != A[31])) begin     // 符号位相同，结果符号位不同即溢出 
                    Ov = 1'b1;
                end
            end
            `SUB: begin
                C = A - B;
                if ((A[31] != B[31]) && (C[31] != A[31])) begin     // 符号位不同，结果符号位不同即溢出
                    Ov = 1'b1;
                end
            end
            `AND:
                C = A & B;
            `OR:
                C = A | B;
            `LUI:
                C = {B[15:0], 16'h0};
            `Other: begin
                // 扩展的 ALU 指令
            end
            default : C = 0;
        endcase
    end

    assign Zero = (A == B);

endmodule
