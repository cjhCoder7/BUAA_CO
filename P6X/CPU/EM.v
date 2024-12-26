`timescale 1ns / 1ps

`include "param.v"

module EM (
	input Clk,
	input Reset,
	input [31:0] E_Instruction,
	input [31:0] E_PC,
	input [31:0] E_AluC,
	input [31:0] E_Imm32,
	input [31:0] E_RT_Data,
	input [4:0] E_RegAddr,
	output reg [31:0] M_Instruction,
	output reg [31:0] M_PC,
	output reg [31:0] M_AluC,
	output reg [31:0] M_Imm32,
	output reg [31:0] M_RT_Data,
	output reg [4:0] M_RegAddr,
	output reg [2:0] M_Tnew
	);
	
	initial begin
		M_Instruction = 32'h0;
		M_PC = 32'h0;
		M_AluC = 32'h0;
		M_Imm32 = 32'h0;
		M_RT_Data = 32'h0;
		M_RegAddr = 5'h0;
		M_Tnew = 32'h0;
	end

	always @(posedge Clk) begin
		if (Reset) begin
			M_Instruction <= 32'h0;
		end
		else begin
			M_Instruction <= E_Instruction;
			M_PC <= E_PC;
			M_AluC <= E_AluC;
			M_Imm32 <= E_Imm32;
			M_RT_Data <= E_RT_Data;
			M_RegAddr <= E_RegAddr;
		end
	end

	// 产生新的值还需要多少个周期
	always @(*) begin
		case (M_Instruction[31:26])
			`RType: begin
				case (M_Instruction[5:0]) 
					`ADD: M_Tnew = 0;
					`SUB: M_Tnew = 0;
					`JR:  M_Tnew = 0;
					default: M_Tnew = 0;
				endcase
			end
			`ORI:		  M_Tnew = 0;
			`LUI: 		  M_Tnew = 0;
			`SW:          M_Tnew = 0;
			`LW: 		  M_Tnew = 1;
			`BEQ: 		  M_Tnew = 0;
			`JAL: 		  M_Tnew = 0;
			default: 	  M_Tnew = 0;
		endcase
	end
	

endmodule