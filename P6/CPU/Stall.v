`timescale 1ns / 1ps

module Stall (
    input [4:0]E_RegAddr,
	input [4:0]M_RegAddr,
    input E_RegWr,
    input M_RegWr,
	input [4:0]D_rs,
	input [4:0]D_rt,
	input [2:0]D_Tuse_rs,
	input [2:0]D_Tuse_rt,
	input [2:0]E_Tnew,
	input [2:0]M_Tnew,
	output Flush
    );

    wire E_Stall_rs = (D_rs == E_RegAddr && D_rs != 0 && E_RegWr == 1) && (E_Tnew > D_Tuse_rs);
    wire E_Stall_rt = (D_rt == E_RegAddr && D_rt != 0 && E_RegWr == 1) && (E_Tnew > D_Tuse_rt);
    wire M_Stall_rs = (D_rs == M_RegAddr && D_rs != 0 && M_RegWr == 1) && (M_Tnew > D_Tuse_rs);
    wire M_Stall_rt = (D_rt == M_RegAddr && D_rt != 0 && M_RegWr == 1) && (M_Tnew > D_Tuse_rt);

    assign Flush = E_Stall_rs || E_Stall_rt || M_Stall_rs || M_Stall_rt;

endmodule