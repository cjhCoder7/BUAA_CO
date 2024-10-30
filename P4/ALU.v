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
    output Zero
    );

    always @(*) begin
        case (ALUop)
            `ADD:
                C = A + B;
            `SUB:
                C = A - B;
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
