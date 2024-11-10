`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:00:17 10/29/2024 
// Design Name: 
// Module Name:    DM 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module DM(
    input [31:0] A,     // 内存中对应的地址
    input [31:0] WD,    // 要写入内存的数据
    input [31:0] PC,    // 对应指令的地址
    input DMWr,         // 写使能端口
    input [2:0] WDsel,  // 写使能端口
    input Clk,
    input Reset,
    output reg [31:0] RD,   // 内存中对应地址所有的数据
    output reg AdEl,  // 取数地址没有字对齐,取数地址超出0x0000 ~ 0x2fff
    output reg AdEs   // 存数地址没有字对齐,存数地址超出0x0000 ~ 0x2fff
    );

    reg [31:0] Datas[0:3071];
    integer i;

    initial begin
        for (i = 0;i < 3072;i = i + 1) begin
            Datas[i] = 32'h0;
        end
        AdEs = 0;
        AdEl = 0;
        RD = 0;
    end

    // 写入操作：时序逻辑
    always @(posedge Clk) begin
        AdEs <= 1'b0;
        if (Reset) begin
            for (i = 0;i < 3072;i = i + 1) begin
                Datas[i] <= 32'h0;
            end
        end
        else begin
            AdEs <= 1'b0;
            if (DMWr) begin
                if (A[1:0] != 2'b00 || A > 32'h0000_2fff || A < 32'h0000_0000) begin
                    AdEs <= 1'b1;
                end else begin
                    Datas[A[11:2]] = WD;
                    $display("@%h: *%h <= %h", PC, A, WD);
                end  
            end
        end
    end

    // 读出操作：组合逻辑
    always @(*) begin
        AdEl = 1'b0;
        if (!DMWr && WDsel == 3'b001) begin
            if (A[1:0] != 2'b00 || A > 32'h0000_2fff || A < 32'h0000_0000) begin
                AdEl = 1'b1;
            end else begin
                RD = Datas[A[11:2]];
            end
        end
    end

endmodule
