`timescale 1ns / 1ps

module D_RF (
	input [4:0] A1,     // rs 寄存器地址
    input [4:0] A2,     // rt 寄存器地址
    input [4:0] A3,     // rd 寄存器地址
    input [31:0] WD,    // 要写入的数据
    input [31:0] PC,    // 当前指令的地址
    input RFWr,
    input Clk,
    input Reset,
    output [31:0] RD1,  // rs 寄存器的值
    output [31:0] RD2   // rt 寄存器的值
    );

    reg [31:0] Registers[0:31];
    integer i;

    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            Registers[i] = 0;
        end
    end

    // 写入操作：时序逻辑
    always @(posedge Clk) begin
        if (Reset) begin
            for (i = 0; i < 32; i = i + 1) begin
                Registers[i] <= 0;
            end
        end
        else begin
            if (A3 == 0) begin
                // 不更改 0 号寄存器
            end
            else if (RFWr) begin
                Registers[A3] <= WD;
                $display("%d@%h: $%d <= %h", $time, PC, A3, WD);
            end
        end
    end

    // 读出操作：组合逻辑
    assign RD1 = (A1 == A3 && RFWr == 1 && A1 != 0) ? WD : Registers[A1];
    assign RD2 = (A2 == A3 && RFWr == 1 && A2 != 0) ? WD : Registers[A2];


endmodule