`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:08:21 10/29/2024 
// Design Name: 
// Module Name:    mips 
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
module mips(
    input clk,
    input reset
    );

    wire [31:0] npc, pc, pc4, instruction, extNum;

    wire [31:0] aluNum, rd1, rd2, dmNum;

    wire [31:0] regData, bData;

    wire [4:0] regAddr;

    wire [1:0] wrSel, bSel;
    wire [2:0] npcOp, wdSel;
    wire extOp, rfWr, dmWr, dmJudge;
    wire [2:0] aluOp; 

    wire zero;

    wire en, req, exlclr;

    wire [31:0] epcout, cp0out;

    wire adel1, adel2, ov, ades;

    wire [4:0] excCodeIn;

    CP0 cp0 (.Clk(clk), .Reset(reset), .En(en), .CP0Add(instruction[15:11]), .CP0In(rd2),
             .CP0Out(cp0out), .VPC(pc), .ExcCodeIn(excCodeIn), .EXLClr(exlclr), .EPCOut(epcout), 
             .Req(req));

    PC Pc (.Clk(clk), .Reset(reset), .NPC(npc), .NowPC(pc));

    NPC Npc(.PC(pc), .NPC(npc), .Imm16(instruction[15:0]), .Imm26(instruction[25:0]),
            .RA32(rd1), .NPCop(npcOp), .PC4(pc4), .EPCout(epcout));

    IM Im(.PC(pc), .Instruction(instruction), .AdEl(adel1));

    Control control(.Opcode(instruction[31:26]), .Funct(instruction[5:0]),
                    .NPCop(npcOp), .WRsel(wrSel), .EXTop(extOp), .WDsel(wdSel), 
                    .RFWr(rfWr), .Bsel(bSel), .ALUop(aluOp), .DMWr(dmWr), .Zero(zero),
                    .EXLClr(exlclr), .Mco(instruction[25:21]), .En(en), .Req(req),
                    .ExcCodeIn(excCodeIn), .Adel_IM(adel1), .Adel_DM(adel2), .Ades(ades), .Ov(ov), .DMJudge(dmJudge));

    MUX4_5 RegAddr(.input0(instruction[20:16]), .input1(instruction[15:11]),
                   .input2(5'd31), .input3(5'b00000), .select(wrSel), .out(regAddr));

    EXT ext(.Imm16(instruction[15:0]), .EXTop(extOp), .Bit32(extNum));

    MUX8_32 RegData(.input0(aluNum), .input1(dmNum), .input2(pc4), 
                    .input3(cp0out), .input4(0), .input5(0), .input6(0), .input7(0),
                    .select(wdSel), .out(regData));

    RF rf(.PC(pc), .Reset(reset), .Clk(clk), .RFWr(rfWr),
          .A1(instruction[25:21]), .A2(instruction[20:16]), .A3(regAddr), .WD(regData),
          .RD1(rd1), .RD2(rd2));

    MUX4_32 BData(.input0(rd2), .input1(extNum),
                  .input2(0), .input3(0), .select(bSel), .out(bData));

    ALU alu(.A(rd1), .B(bData), .ALUop(aluOp), .Zero(zero), .C(aluNum), .Ov(ov));

    DM dm(.PC(pc), .Reset(reset), .Clk(clk), .WD(rd2), .DMWr(dmWr), .DMJudge(dmJudge), .A(aluNum),
          .RD(dmNum),
          .AdEl(adel2), .AdEs(ades), .WDsel(wdSel));

endmodule
