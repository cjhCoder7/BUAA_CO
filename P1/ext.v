`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:55:48 10/05/2024 
// Design Name: 
// Module Name:    ext 
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
module ext(
    input [15:0] imm,
    input [1:0] EOp,
    output reg [31:0] ext
    );

    always @(*) begin
        case (EOp)
            2'b00: begin
                ext = {{16{imm[15]}}, imm[15:0]};
            end
            2'b01: begin
                ext = {{16{1'b0}}, imm[15:0]};
            end
            2'b10: begin
                ext = {imm[15:0], {16{1'b0}}};
            end
            2'b11: begin
                ext = {{16{imm[15]}}, imm[15:0]} << 2'b10;
            end
            default : /* default */;
        endcase
    end


endmodule
