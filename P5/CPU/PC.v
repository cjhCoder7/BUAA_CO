`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:55:20 10/29/2024 
// Design Name: 
// Module Name:    PC 
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
module PC(
    input Clk,
    input Reset,
    input [31:0] NPC,
    output reg [31:0] NowPC
    );

    initial begin
        NowPC <= 32'h0000_3000;
    end

    always @(posedge Clk) begin
        if(Reset) begin
            // 同步复位
            NowPC <= 32'h0000_3000;
        end
        else begin
            NowPC <= NPC;
        end
    end


endmodule
