`timescale 1ns / 1ps

`define codeNum 4096

module F_IM (
    input [31:0] PC,
    output [31:0] Instruction
    );
	 
	// 分配指令存储器
	reg [31:0] Registers[0:`codeNum - 1];
	integer i;

	initial begin
		for (i = 0; i < `codeNum; i = i + 1) begin
			Registers[i] = 32'h0;
		end
		$readmemh("code.txt", Registers);
	end

	wire [31:0] tmpPC;
	assign tmpPC = PC - 32'h0000_3000;
	assign Instruction = Registers[tmpPC[13:2]];

endmodule