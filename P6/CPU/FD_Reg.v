`timescale 1ns / 1ps

module FD_Reg (
	input Clk,
	input Reset,
	input Flush,				        // 如果Flush等于0,那么可以写值，否则阻塞
	input [31:0] F_Instruction,
	input [31:0] F_PC,
	output reg [31:0] D_Instruction,
	output reg [31:0] D_PC
	);

	initial begin
		D_Instruction <= 32'h0;
		D_PC <= 32'h0;
	end

	always @(posedge Clk) begin
		if (Reset) begin
			D_Instruction <= 32'h0;
			D_PC <= 32'h0;
		end
		else begin
			if (Flush == 0) begin
				D_Instruction <= F_Instruction;
				D_PC <= F_PC;
			end
			else begin
				// 保持FD流水寄存器
				D_Instruction <= D_Instruction;
				D_PC <= D_PC;
			end
		end
	end

endmodule