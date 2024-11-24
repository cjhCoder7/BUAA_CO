`timescale 1ns / 1ps

module D_NPC(
    input [31:0] F_PC,
    input [31:0] D_PC,
    input [15:0] Imm16,
    input [25:0] Imm26,
    input [31:0] RA32,
    input [2:0] NPCop,
    input cmpSuc,
    output reg [31:0] NPC
    );

    initial begin
        NPC = 32'h0000_3000;
    end

    always @(*) begin
        if (NPCop == 2'b00) begin
            NPC = F_PC + 4;
        end
        else if(NPCop == 2'b01) begin
            if (cmpSuc) begin
                // beq 成功跳转
                NPC = D_PC + 4 + {{14{Imm16[15]}}, Imm16, 2'b00};
            end else begin
                // beq 不成功跳转
                NPC = F_PC + 4;
            end 
        end
        else if(NPCop == 2'b10) begin
            // J 型指令跳转（j/jal）
            NPC = {F_PC[31:28], Imm26, 2'b00};
        end
        else if(NPCop == 2'b11) begin
            // jr 指令读取 $ra 寄存器，成功跳转
            NPC = RA32;
        end
        else begin
            NPC = 32'h0000_3000;
        end
    end

endmodule