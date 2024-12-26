`timescale 1ns / 1ps

module mips (
	input clk,
	input reset
	);
	/**********  Declaration  **********/
	/**********  F  **********/
	wire [31:0] f_pc, f_instruction;
	wire [31:0] f_pc_in;
	wire f_pc_en;
	/*************************/
	/**********  FD  **********/
	wire NOP_insert;
	wire [31:0] d_pc, d_instruction;
	/*************************/
	/**********  D  **********/
	wire [31:0] d_rs, d_rt;
	wire [31:0] fwd_d_rs, fwd_d_rt;

	wire [4:0] d_regAddr;
	wire [31:0] d_npc;
	wire [31:0] d_imm32;

	wire d_cmpSuc;
	wire [1:0] d_CMPop;
	wire d_extOp;
	wire [2:0] d_regAddrSel;
	wire [2:0] d_npcOp;
	/*************************/
	/**********  DE  **********/
	wire [31:0] e_pc, e_instruction;
	wire [31:0] e_rs, e_rt, e_imm32;
	wire [4:0] e_regAddr;
	wire [2:0] e_tnew;
	/*************************/
	/**********  E  **********/
	wire [31:0] e_aluB, e_aluC;
	wire [31:0] fwd_e_rs, fwd_e_rt;

	wire e_regWr;
	wire [31:0] e_regData;
	wire [2:0] e_regDataSel;

	wire [2:0] e_Bsel;
	wire [2:0] e_aluOp;
	/*************************/
	/**********  EM  **********/
	wire [31:0] m_instruction, m_pc;
	wire [31:0] m_aluC, m_rt, m_imm32;
	wire [4:0] m_regAddr;
	wire [2:0] m_tnew;
	/*************************/
	/**********  M  **********/
	wire m_dmWr;

	wire m_regWr;
	wire [31:0] fwd_m_rs, fwd_m_rt;
	wire [31:0] m_regData;
	wire [2:0] m_regDataSel;

	wire [31:0] m_dmData;
	/*************************/
	/**********  MW  **********/
	wire [31:0] w_instruction, w_pc;
	wire [4:0] w_regAddr;
	wire [31:0] w_dmData, w_aluC;
	/*************************/
	/**********  W  **********/
	wire w_regWr;
	wire [31:0] w_regData;
	wire [2:0] w_regDataSel;
	/*************************/
	/**********  阻塞  **********/
	wire [2:0] d_tuse_rs, d_tuse_rt;
	wire flush;				// 阻塞

	Stall stall(
		.E_RegAddr(e_regAddr),
		.M_RegAddr(m_regAddr),
		.E_RegWr(e_regWr),
		.M_RegWr(m_regWr),
		.D_rs(d_instruction[25:21]),
		.D_rt(d_instruction[20:16]),
		.D_Tuse_rs(d_tuse_rs),
		.D_Tuse_rt(d_tuse_rt),
		.E_Tnew(e_tnew),
		.M_Tnew(m_tnew),
		.Flush(flush)
		);

	/*************************/
	/**********  Stage_F  **********/
	assign f_pc_in = d_npc;

	assign f_pc_en = ~flush;

	F_PC F_Stage_PC(
		.Clk    (clk),
		.Reset  (reset),
		.F_PC_En(f_pc_en),	// pc 使能信号
		.PC_In  (f_pc_in),  // input npc
		.PC     (f_pc)		// output pc
		);

	F_IM F_Stage_IM(
		.PC         (f_pc),			// input pc
		.Instruction(f_instruction) // output instruction
		);
	/*******************************/
	/**********  F_D  **********/
	assign NOP_insert = 1'b0;

	FD FD_Reg(
		.Clk          (clk),
		.Reset        (reset),

		.F_PC         (f_pc),
		.F_Instruction(f_instruction),
		.Flush        (flush),			// 用于阻塞

		.NOP_Insert   (NOP_insert),

		.D_Instruction(d_instruction),
		.D_PC         (d_pc)
		);
	/*******************************/
	/**********  Stage_D  **********/
	Control D_Control(
		.Opcode(d_instruction[31:26]),
		.Funct (d_instruction[5:0]),

		.EXTop (d_extOp),
		.NPCop (d_npcOp),
		.WRsel (d_regAddrSel),
		.D_Tuse_rs(d_tuse_rs),
		.D_Tuse_rt(d_tuse_rt),
		.CMPop (d_CMPop)
		);

	D_RF D_Stage_RF(
		.Clk  (clk),
		.Reset(reset),
		.PC   (w_pc),
		.A1   (d_instruction[25:21]),
		.A2   (d_instruction[20:16]),
		.A3   (w_regAddr),
		.WD   (w_regData),
		.RFWr (w_regWr),
		.RD1  (d_rs),
		.RD2  (d_rt)
		);

	D_EXT D_Stage_EXT(
		.Imm16(d_instruction[15:0]),
		.EXTop(d_extOp),
		.Bit32(d_imm32)
		);

	D_NPC D_Stage_NPC(
		.F_PC  (f_pc),
		.D_PC  (d_pc),
		.Imm16 (d_instruction[15:0]),
		.Imm26 (d_instruction[25:0]),
		.RA32  (fwd_d_rs),
		.NPCop (d_npcOp),
		.cmpSuc(d_cmpSuc),
		.NPC   (d_npc)
		);

	// 转发
	assign fwd_d_rs = (d_instruction[25:21] == 5'b0) ? 0 :
					  (d_instruction[25:21] == e_regAddr && e_regWr == 1) ? e_regData :
					  (d_instruction[25:21] == m_regAddr && m_regWr == 1) ? m_regData : d_rs;

	assign fwd_d_rt = (d_instruction[20:16] == 5'b0) ? 0 :
					  (d_instruction[20:16] == e_regAddr && e_regWr == 1) ? e_regData :
					  (d_instruction[20:16] == m_regAddr && m_regWr == 1) ? m_regData : d_rt;

	// CMP 比较器
	D_CMP D_Stage_CMP(
		.rt(fwd_d_rt),
		.rs(fwd_d_rs),
		.CMPop(d_CMPop),
		.cmpSuc(d_cmpSuc)
		);

	// 选择d_regAddr
	assign d_regAddr = (d_regAddrSel == 0) ? d_instruction[20:16] : 
					   (d_regAddrSel == 1) ? d_instruction[15:11] : 
					   (d_regAddrSel == 2) ? 5'd31 : 5'd0;
	/*******************************/
	/**********  D_E  **********/
	DE DE_Reg(
		.Clk          (clk),
		.Reset        (reset),

		.D_PC         (d_pc),
		.D_Instruction(d_instruction),
		.Flush        (flush),
		.D_RS_Data    (fwd_d_rs),
		.D_RT_Data    (fwd_d_rt),
		.D_RegAddr    (d_regAddr),
		.D_Imm32      (d_imm32),

		.E_Instruction(e_instruction),
		.E_PC         (e_pc),
		.E_RS_Data    (e_rs),
		.E_RT_Data    (e_rt),
		.E_RegAddr    (e_regAddr),
		.E_Imm32      (e_imm32),
		.E_Tnew       (e_tnew)
		);
	/*******************************/
	/**********  Stage_E  **********/
	Control E_Control(
		.Opcode(e_instruction[31:26]),
		.Funct (e_instruction[5:0]),

		.Bsel  (e_Bsel),
		.ALUop (e_aluOp),
		.WDsel (e_regDataSel),
		.RFWr  (e_regWr)
		);

	// 选择进入ALU的B端口的值
	assign e_aluB = (e_Bsel == 0) ? fwd_e_rt : 
				    (e_Bsel == 1) ? e_imm32 : 0;

	E_ALU E_Stage_ALU(
		.A    (fwd_e_rs),
		.B    (e_aluB),
		.C    (e_aluC),
		.ALUop(e_aluOp)
		);

	// 转发
	assign fwd_e_rs = (e_instruction[25:21] == 5'b0) ? 0 :
					  (e_instruction[25:21] == m_regAddr && m_regWr == 1) ? m_regData : 
					  (e_instruction[25:21] == w_regAddr && w_regWr == 1) ? w_regData : e_rs;

	assign fwd_e_rt = (e_instruction[20:16] == 5'b0) ? 0 :
					  (e_instruction[20:16] == m_regAddr && m_regWr == 1) ? m_regData : 
					  (e_instruction[20:16] == w_regAddr && w_regWr == 1) ? w_regData : e_rt;

	// 转出去的数据, e级只可能转出去PC
	assign e_regData = (e_regDataSel == 2) ? e_pc + 8 : 0;

	/*******************************/
	/**********  E_M  **********/
	EM EM_Reg(
		.Clk          (clk),
		.Reset        (reset),

		.E_PC         (e_pc),
		.E_Instruction(e_instruction),
		.E_Imm32      (e_imm32),
		.E_RT_Data    (fwd_e_rt),
		.E_AluC       (e_aluC),
		.E_RegAddr    (e_regAddr),
		
		.M_Instruction(m_instruction),
		.M_PC         (m_pc),
		.M_AluC       (m_aluC),
		.M_Imm32      (m_imm32),
		.M_RT_Data    (m_rt),
		.M_RegAddr    (m_regAddr),
		.M_Tnew       (m_tnew)
		);
	/*******************************/
	/**********  Stage_M  **********/
	Control M_Control(
		.Opcode(m_instruction[31:26]),
		.Funct (m_instruction[5:0]),

		.DMWr  (m_dmWr),
		.WDsel (m_regDataSel),
		.RFWr  (m_regWr)
		);

	M_DM M_Stage_DM(
		.Clk  (clk),
		.Reset(reset),
		.PC   (m_pc),
		.A    (m_aluC),
		.WD   (fwd_m_rt),
		.DMWr (m_dmWr),
		.RD   (m_dmData)
		);

	// 转发
	assign fwd_m_rt = (m_instruction[20:16] == 5'b0) ? 0 :
					  (m_instruction[20:16] == w_regAddr && w_regWr == 1) ? w_regData : m_rt;
	
	// 转出去的数据, m级可能转出去PC和ALU计算出来的结果
	assign m_regData = (m_regDataSel == 2) ? m_pc + 8 :
					   (m_regDataSel == 0) ? m_aluC : 0;

	/*******************************/
	/**********  M_W  **********/
	MW MW_Reg(
		.Clk          (clk),
		.Reset        (reset),

		.M_PC         (m_pc),
		.M_Instruction(m_instruction),
		.M_AluC       (m_aluC),
		.M_DMrd       (m_dmData),
		.M_RegAddr    (m_regAddr),

		.W_Instruction(w_instruction),
		.W_PC         (w_pc),
		.W_DMrd       (w_dmData),
		.W_AluC       (w_aluC),
		.W_RegAddr    (w_regAddr)
		);
	/*******************************/
	/**********  Stage_W  **********/
	Control W_Control(
		.Opcode(w_instruction[31:26]),
		.Funct (w_instruction[5:0]),

		.WDsel (w_regDataSel),
		.RFWr  (w_regWr)
		);

	assign w_regData = (w_regDataSel == 0) ? w_aluC :
					   (w_regDataSel == 1) ? w_dmData : 
					   (w_regDataSel == 2) ? w_pc + 8 : 0;

	/*******************************/
endmodule