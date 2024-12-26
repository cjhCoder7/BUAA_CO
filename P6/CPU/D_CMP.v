`timescale 1ns / 1ps

module D_CMP (
	input [31:0] rt,
    input [31:0] rs,
    input [1:0] CMPop,
    output reg cmpSuc
    );

    initial begin
        cmpSuc = 1'b0;
    end

    always @ (*) begin
        if (CMPop == 2'b00) begin
            cmpSuc = (rt == rs);
        end
        else if (CMPop == 2'b01) begin
            // 待补充的判断条件
        end
        else if (CMPop == 2'b10) begin
            // 待补充的判断条件
        end
        else begin
            // 待补充的判断条件
        end
    end

endmodule