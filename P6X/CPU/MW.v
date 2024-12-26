`timescale 1ns / 1ps

module MW (
	input Clk,
	input Reset,
	input [31:0] M_PC,
	input [31:0] M_Instruction,
	input [31:0] M_DMrd,
	input [31:0] M_AluC,
	input [4:0] M_RegAddr,
	output reg [31:0] W_Instruction,
	output reg [31:0] W_PC,
	output reg [31:0] W_DMrd,
	output reg [31:0] W_AluC,
	output reg [4:0] W_RegAddr
	);

	initial begin
		W_Instruction = 32'h0;
		W_PC = 32'h0;
		W_DMrd = 32'h0;
		W_AluC = 32'h0;
		W_RegAddr = 5'h0;
	end

	always @(posedge Clk) begin
		if (Reset) begin
			W_Instruction <= 32'h0;
			W_PC <= 32'h0;
			W_DMrd <= 32'h0;
			W_AluC <= 32'h0;
			W_RegAddr <= 5'h0;
		end
		else begin
			W_Instruction <= M_Instruction;
			W_PC <= M_PC;
			W_AluC <= M_AluC;
			W_DMrd <= M_DMrd;
			W_RegAddr <= M_RegAddr;
		end
	end
	
endmodule