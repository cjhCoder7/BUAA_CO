`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:16:12 10/29/2024 
// Design Name: 
// Module Name:    NPC 
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
module NPC(
    input [31:0] PC,
    input [15:0] Imm16,
    input [25:0] Imm26,
    input [31:0] RA32,
    input [31:0] EPCout,
    input [2:0] NPCop,
    output reg [31:0] NPC,
    output [31:0] PC4
    );

    assign PC4 = PC + 4;

    always @(*) begin
        if (NPCop == 3'b000) begin
            NPC = PC + 4;
        end
        else if(NPCop == 3'b001) begin
            // beq 成功跳转
            NPC = PC + 4 + {{14{Imm16[15]}}, Imm16, 2'b00};
        end
        else if(NPCop == 3'b010) begin
            // J 型指令跳转（j/jal）
            NPC = {PC[31:28], Imm26, 2'b00};
        end
        else if(NPCop == 3'b011) begin
            // jr 指令读取 $ra 寄存器，成功跳转
            NPC = RA32;
        end
        else if(NPCop == 3'b100) begin
            NPC = EPCout;
        end
        else if(NPCop == 3'b101) begin
            NPC = 32'h0000_4180;
        end
        else begin
            NPC = 32'h0000_3000;
        end
    end

endmodule
