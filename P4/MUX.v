`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:14:21 10/29/2024 
// Design Name: 
// Module Name:    MUX 
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
module MUX4_5(
    input [4:0] input0,
    input [4:0] input1,
    input [4:0] input2,
    input [4:0] input3,
    input [1:0] select,
    output [4:0] out
    );
    // 输入为4个，每一个都是5位
    assign out = (select == 2'b00) ? input0 :
                 (select == 2'b01) ? input1 :
                 (select == 2'b10) ? input2 : input3;

endmodule

module MUX4_32(
    input [31:0] input0,
    input [31:0] input1,
    input [31:0] input2,
    input [31:0] input3,
    input [1:0] select,
    output [31:0] out
    );
    // 输入为4个，每一个都是32位
    assign out = (select == 2'b00) ? input0 :
                 (select == 2'b01) ? input1 :
                 (select == 2'b10) ? input2 : input3;

endmodule
