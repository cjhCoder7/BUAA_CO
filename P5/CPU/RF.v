`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:51:58 10/29/2024 
// Design Name: 
// Module Name:    RF 
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
module RF(
    input [4:0] A1, // rs 寄存器地址
    input [4:0] A2, // rt 寄存器地址
    input [4:0] A3, // rd 寄存器地址
    input [31:0] WD,    // 要写入的数据
    input [31:0] PC,    // 当前指令的地址
    input RFWr,
    input Clk,
    input Reset,
    output reg [31:0] RD1,  // rs 寄存器的值
    output reg [31:0] RD2   // rt 寄存器的值
    );

    reg [31:0] Registers[0:31];
    integer i;

    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            Registers[i] <= 0;
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
            if (A3 == 5'b00000) begin
                // 不更改 0 号寄存器
            end
            else if (RFWr) begin
                Registers[A3] <= WD;
                $display("@%h: $%d <= %h", PC, A3, WD);
            end
        end
    end

    // 读出操作：组合逻辑
    always @(*) begin
        RD1 = Registers[A1];
        RD2 = Registers[A2];
    end


endmodule
