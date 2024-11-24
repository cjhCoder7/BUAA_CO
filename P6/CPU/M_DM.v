`timescale 1ns / 1ps

module M_DM(
	input Clk,
    input Reset,
    input [31:0] A,     // 内存中对应的地址
    input [31:0] WD,    // 要写入内存的数据
    input [31:0] PC,    // 对应指令的地址
    input DMWr,         // 写使能端口
    output [31:0] RD    // 内存中对应地址所有的数据
    );

    reg [31:0] Datas[0:3071];
    integer i;

    initial begin
        for (i = 0;i < 3072;i = i + 1) begin
            Datas[i] = 32'h0;
        end
    end

    // 写入操作：时序逻辑
    always @(posedge Clk) begin
        if (Reset) begin
            for (i = 0;i < 3072;i = i + 1) begin
                Datas[i] = 32'h0;
            end
        end
        else begin
            if (DMWr) begin
                Datas[A[13:2]] = WD;
                $display("%d@%h: *%h <= %h", $time, PC, A, WD);
            end
        end
    end

    // 读出操作：组合逻辑
    assign RD = Datas[A[13:2]];

endmodule