`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:32:49 10/29/2024 
// Design Name: 
// Module Name:    EXT 
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
module EXT(
    input [15:0] Imm16,
    input EXTop,
    output reg [31:0] Bit32
    );

    always @(*) begin
        if (EXTop == 0) begin
            Bit32 = {16'h0, Imm16};
        end
        else if (EXTop == 1) begin
            Bit32 = {{16{Imm16[15]}}, Imm16};
        end
        else begin
            Bit32 = 32'h0;
        end
    end


endmodule
