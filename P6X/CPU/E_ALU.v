`timescale 1ns / 1ps

`define ADDop   3'b000
`define SUBop   3'b001
`define ANDop   3'b010
`define ORop    3'b011
`define LUIop   3'b100
`define Other   3'b101

module E_ALU(
    input [31:0] A,
    input [31:0] B,
    output reg [31:0] C,
    input [2:0] ALUop
    );

	initial begin
		C = 0;
	end

    always @(*) begin
        case (ALUop)
            `ADDop:
                C = A + B;
            `SUBop:
                C = A - B;
            `ANDop:
                C = A & B;
            `ORop:
                C = A | B;
            `LUIop:
                C = B << 16;
            `Other: begin
                // 扩展的 ALU 指令
            end
            default : C = 0;
        endcase
    end

endmodule