`timescale 1ns / 1ps

`include "param.v"

module DE (
	input Clk,
	input Reset,
	input Flush,						// 如果Flush等于0,那么可以写值，否则清零
	input [31:0] D_Instruction,
	input [31:0] D_PC,
	input [31:0] D_RS_Data,
	input [31:0] D_RT_Data,
	input [4:0] D_RegAddr,
	input [31:0] D_Imm32,			// 16 位立即数经 EXT 扩展的结果
	output reg [31:0] E_Instruction,
	output reg [31:0] E_PC,
	output reg [31:0] E_RS_Data,
	output reg [31:0] E_RT_Data,
	output reg [4:0] E_RegAddr,
	output reg [31:0] E_Imm32,
	output reg [2:0] E_Tnew
	);

	initial begin
		E_Instruction = 32'h0;
		E_PC = 32'h0;
		E_RS_Data = 32'h0;
		E_RT_Data = 32'h0;
		E_RegAddr = 5'h0;
		E_Imm32 = 32'h0;
		E_Tnew = 32'h0;
	end

	always @(posedge Clk) begin
		if (Reset) begin
			E_Instruction <= 32'h0;
			E_PC <= 32'h0;
			E_RS_Data <= 32'h0;
			E_RT_Data <= 32'h0;
			E_RegAddr <= 5'h0;
			E_Imm32 <= 32'h0;
		end
		else begin
			if (Flush == 0) begin
				E_Instruction <= D_Instruction;
				E_PC <= D_PC;
				E_RS_Data <= D_RS_Data;
				E_RT_Data <= D_RT_Data;
				E_RegAddr <= D_RegAddr;
				E_Imm32 <= D_Imm32;
			end else begin
				E_Instruction <= 32'h0;
				E_PC <= 32'h0;
				E_RS_Data <= 32'h0;
				E_RT_Data <= 32'h0;
				E_RegAddr <= 5'h0;
				E_Imm32 <= 32'h0;
			end
		end
	end

	// 产生新的值还需要多少个周期
	always @(*) begin
		case (E_Instruction[31:26])
			`RType: begin
				case (E_Instruction[5:0]) 
					`ADD: E_Tnew = 1;
					`SUB: E_Tnew = 1;
					`JR:  E_Tnew = 0;
					default: E_Tnew = 0;
				endcase
			end
			`ORI:		  E_Tnew = 1;
			`LUI: 		  E_Tnew = 1;
			`SW:          E_Tnew = 0;
			`LW: 		  E_Tnew = 2;
			`BEQ: 		  E_Tnew = 0;
			`JAL: 		  E_Tnew = 0;
			default: 	  E_Tnew = 0;
		endcase
	end

endmodule