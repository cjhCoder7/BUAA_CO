`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:15:29 10/06/2024 
// Design Name: 
// Module Name:    expr 
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
module expr(
    input clk,
    input clr,
    input [7:0] in,
    output reg out
    );

    parameter state0 = 3'b000;   // empty string
    parameter state1 = 3'b001;   // single number
    parameter state2 = 3'b010;   // single number + string
    parameter state3 = 3'b011;   // single number + string + single number
    parameter state4 = 3'b100;   // illegal string

    reg [2:0] state = 3'b000;
    reg [2:0] nextState = 3'b000;

    wire number = (in >= "0" && in <= "9") ? 1 : 0;
    wire operate = (in == "+" || in == "*") ? 1 : 0;

    always @(state, in) begin
        case (state)
            state0: begin
                if (number) nextState = state1;
                else if (in == 0) nextState = state0;
                else nextState = state4;
            end
            state1: begin
                if (operate) nextState = state2;
                else nextState = state4;
            end
            state2: begin
                if (number) nextState = state3;
                else nextState = state4;
            end
            state3: begin
                if (operate) nextState = state2;
                else nextState = state4;
            end
            state4: begin
                nextState = state4;
            end
            default : nextState = 3'b000;
        endcase
    end

    always @(posedge clk or posedge clr) begin
        if (clr) begin
            nextState <= state0;
            state <= state0;
        end
        else state <= nextState;
    end

    always @(state) begin
        if (state == state1 || state == state3) out = 1;
        else out = 0;
    end


endmodule
