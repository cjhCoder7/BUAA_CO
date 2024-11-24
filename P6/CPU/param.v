`timescale 1ns / 1ps

`define RType 6'b000000		// R 类型指令的opcode
`define ADD   6'b100000     // funct
`define SUB   6'b100010     // funct
`define ORI   6'b001101     // opcode
`define LUI   6'b001111     // opcode
`define LW    6'b100011     // opcode
`define SW    6'b101011     // opcode
`define BEQ   6'b000100     // opcode
`define JAL   6'b000011     // opcode
`define JR    6'b001000     // funct