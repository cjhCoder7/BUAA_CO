`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:32:49 10/06/2024 
// Design Name: 
// Module Name:    BlockChecker 
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
module BlockChecker(
    input clk,
    input reset,
    input [7:0] in,
    output reg result
    );

    function [7:0] toLower(input [7:0] letter);
        toLower = (letter >= "A" && letter <= "Z") ? letter - ("A" - "a") : letter;
    endfunction

    parameter state0 = 4'b0000; // space or empty or , ; .
    parameter state1 = 4'b0001; // b
    parameter state2 = 4'b0010; // e 
    parameter state3 = 4'b0011; // g
    parameter state4 = 4'b0100; // i
    parameter state5 = 4'b0101; // n
    parameter state6 = 4'b0110; // e
    parameter state7 = 4'b0111; // n
    parameter state8 = 4'b1000; // d
    parameter state9 = 4'b1001; // other words


    reg[3:0] nextState = 0;
    reg[31:0] beginCount = 0;
    reg [31:0] alwaysEnd = 0;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            nextState <= state0;
            beginCount <= 0;
            alwaysEnd <= 0;
        end
        else if (alwaysEnd != 2) begin       
        case (nextState)
            state0 : begin
                if (toLower(in) == "b") nextState <= state1;
                else if (toLower(in) == "e") nextState <= state6;
                else if (toLower(in) >= "a" && toLower(in) <= "z") nextState <= state9;
                else if(toLower(in) == " ") nextState <= state0;
            end
            state1 : begin
                if (toLower(in) == "e") nextState <= state2;
                else if (toLower(in) >= "a" && toLower(in) <= "z") nextState <= state9;
                else if (toLower(in) < "a" || toLower(in) > "z") nextState <= state0;
            end
            state2 : begin
                if (toLower(in) == "g") nextState <= state3;
                else if (toLower(in) >= "a" && toLower(in) <= "z") nextState <= state9;
                else if (toLower(in) < "a" || toLower(in) > "z") nextState <= state0;
            end
            state3 : begin
                if (toLower(in) == "i") nextState <= state4;
                else if (toLower(in) >= "a" && toLower(in) <= "z") nextState <= state9;
                else if (toLower(in) < "a" || toLower(in) > "z") nextState <= state0;
            end
            state4 : begin
                if (toLower(in) == "n") begin
                    nextState <= state5;
                    beginCount <= beginCount + 1;
                end
                else if (toLower(in) >= "a" && toLower(in) <= "z") nextState <= state9;
                else if (toLower(in) < "a" || toLower(in) > "z") nextState <= state0;
            end
            state5 : begin
                if (toLower(in) < "a" || toLower(in) > "z") nextState <= state0;
                else if (toLower(in) >= "a" && toLower(in) <= "z") begin 
                    beginCount <= beginCount - 1;
                    nextState <= state9;
                end
            end
            state6 : begin
                if (toLower(in) == "n") nextState <= state7;
                else if (toLower(in) >= "a" && toLower(in) <= "z") nextState <= state9;
                else if (toLower(in) < "a" || toLower(in) > "z") nextState <= state0;
            end
            state7 : begin
                if (toLower(in) == "d") begin
                    nextState <= state8;
                    if (beginCount > 0 && alwaysEnd != 2) beginCount <= beginCount - 1;
                    else if (beginCount == 0 && alwaysEnd != 2) alwaysEnd <= 1;
                end
                else if (toLower(in) >= "a" && toLower(in) <= "z") nextState <= state9;
                else if (toLower(in) < "a" || toLower(in) > "z") nextState <= state0;
            end
            state8 : begin
                if (toLower(in) < "a" || toLower(in) > "z") begin 
                    nextState <= state0;
                    if (alwaysEnd == 1) begin
                        alwaysEnd <= 2;
                    end
                end
                else if (toLower(in) >= "a" && toLower(in) <= "z") begin  
                    nextState <= state9;
                    if (alwaysEnd == 0) beginCount <= beginCount + 1;
                    else if (alwaysEnd == 1) begin
                        alwaysEnd <= 0;
                    end
                end
            end
            state9 : begin
                if (toLower(in) < "a" || toLower(in) > "z") nextState <= state0;
                else if (toLower(in) >= "a" && toLower(in) <= "z") nextState <= state9;
            end
            default : nextState <= nextState;
        endcase
        end
    end

    always @(*) begin
        if (alwaysEnd > 0 || beginCount != 0) result = 0;
        else if (alwaysEnd == 0 && beginCount == 0) result = 1;
    end

endmodule
