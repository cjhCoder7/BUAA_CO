`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:14:11 10/29/2024 
// Design Name: 
// Module Name:    IM 
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

`define codeNum  4096 //4048

module IM(
    input [31:0] PC,
    output reg [31:0] Instruction,
    output reg AdEl	// 判断是否PC没有对齐，或者PC超出范围
    );
	 
	// 分配指令存储器
	reg [31:0] Registers[0:`codeNum - 1];
	integer i;

	initial begin
		// 初始化指令存储器，全部置零
		for (i = 0; i < `codeNum; i = i + 1) begin
			Registers[i] = 32'h0;
		end
		// 从文件加载指令
		$readmemh("code.txt", Registers);
	end

	// 取出指令，忽略最低两位，保证读出的指令是连续的s
	reg [31:0] tmpPC;

	always @(*) begin
		AdEl = 1'b0;
		if (PC[1:0] != 2'b00 || PC > 32'h0000_6ffc || PC < 32'h0000_3000) begin
			AdEl = 1'b1;	// AdEl == 4
			Instruction = 32'h0000_0000;	// Instruction变为nop
		end
		else begin
			tmpPC = PC-32'h0000_3000;
			Instruction = Registers[tmpPC[13:2]];
		end 
	end

endmodule

