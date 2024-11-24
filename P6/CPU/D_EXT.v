`timescale 1ns / 1ps

module D_EXT (
	input [15:0] Imm16,
    input EXTop,
    output reg [31:0] Bit32
    );

    always @(*) begin
        if (EXTop == 0) begin
            Bit32 = {16'h0, Imm16};
        end
        else if (EXTop == 1) begin
            Bit32 = {{16{Imm16[15]}}, Imm16};
        end
        else begin
            Bit32 = 32'h0;
        end
    end

endmodule