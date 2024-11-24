`timescale 1ns / 1ps

module F_PC (
	input Clk,
	input Reset,
	input F_PC_En,
    input [31:0] PC_In,
    output reg [31:0] PC
    );

    initial begin
        PC = 32'h0000_3000;
    end

    always @(posedge Clk) begin
        if(Reset) begin
            PC <= 32'h0000_3000;
        end
        else if (F_PC_En) begin
            PC <= PC_In;
        end
    end

endmodule