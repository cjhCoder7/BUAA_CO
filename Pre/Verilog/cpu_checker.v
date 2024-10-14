module cpu_checker(
    input clk,                                   // Clock signal
    input reset,                                 // Synchronous reset signal, resets the current state and output    
    input [7:0] char,                            // Character stream input
    output reg [1:0] format_type                 // 2'b00: Format error; 2'b01: Register information sequence; 2'b10: Data memory information sequence
    );

    reg [4:0] decCount, hexCount;                // Decimal and Hexadecimal counters

    // State definitions
    parameter init = 4'd0;                       // Initial state
    parameter s1 = 4'd1;                         // Read '^'
    parameter s2 = 4'd2;                         // Read decimal number
    parameter s3 = 4'd3;                         // Read '@'
    parameter s4 = 4'd4;                         // Read hexadecimal number
    parameter s5 = 4'd5;                         // Read ':'
    parameter s6 = 4'd6;                         // Read '$'
    parameter s7 = 4'd7;                         // Read '*'
    parameter s8 = 4'd8;                         // Read decimal number for register
    parameter s9 = 4'd9;                         // Read hexadecimal number for address
    parameter s10 = 4'd10;                       // Read space
    parameter s11 = 4'd11;                       // Read '<'
    parameter s12 = 4'd12;                       // Read '='
    parameter s13 = 4'd13;                       // Read hexadecimal number for data
    parameter s14 = 4'd14;                       // Final state

    reg [4:0] stateNext;                         // state registers
    reg typeState;                               // Type state (0: register, 1: memory)

    // Input character checks
    wire digit = (char >= "0" && char <= "9");   
    wire hexdigit = digit || (char >= "a" && char <= "f"); 

    // State transition logic
    always @(posedge clk) begin
		if (reset) begin
            stateNext <= init;
            typeState <= 0;
            decCount <= 0;
            hexCount <= 0;
        end
        case (stateNext)
            init: begin
                if (char == "^") stateNext <= s1;
            end
            s1: begin
                if (digit) begin
                    stateNext <= s2;
                    decCount <= 1;
                end else if (char == "^") stateNext <= s1;
                else stateNext <= init;
            end
            s2: begin
                if (digit && decCount < 4) decCount <= decCount + 1;
                else if (char == "@") begin
                    stateNext <= s3;
                    decCount <= 0;
                end else if (char == "^") stateNext <= s1;
                else stateNext <= init;
            end
            s3: begin
                if (hexdigit) begin
                    stateNext <= s4;
                    hexCount <= 1;
                end else if (char == "^") stateNext <= s1;
                else stateNext <= init;
            end
            s4: begin
                if (hexdigit && hexCount < 8) hexCount <= hexCount + 1;
                else if (char == ":" && hexCount == 8) begin
                    stateNext <= s5;
                    hexCount <= 0;
                end else if (char == "^") stateNext <= s1;
                else stateNext <= init;
            end
            s5: begin
                if (char == " ") stateNext <= s5;
                else if (char == "$") stateNext <= s6;
                else if (char == "*") stateNext <= s7;
                else if (char == "^") stateNext <= s1;
                else stateNext <= init;
            end
            s6: begin
                if (digit) begin
                    stateNext <= s8;
                    decCount <= 1;
                end else if (char == "^") stateNext <= s1;
                else stateNext <= init;
            end
            s7: begin
                if (hexdigit) begin
                    stateNext <= s9;
                    hexCount <= 1;
                end else if (char == "^") stateNext <= s1;
                else stateNext <= init;
            end
            s8: begin
                if (digit && decCount < 4) decCount <= decCount + 1;
                else if (char == " ") begin
                    stateNext <= s10;
                    typeState <= 0;                // Register information
                    decCount <= 0;
                end else if (char == "<") begin
                    stateNext <= s11;
                    typeState <= 0;                // Register information
                    decCount <= 0;
                end else if (char == "^") stateNext <= s1;
                else stateNext <= init;
            end
            s9: begin
                if (hexdigit == 1 && hexCount < 7) hexCount <= hexCount + 1;
                else if (hexdigit == 1 && hexCount == 7) begin
                    stateNext <= s10;
                    typeState <= 1;                // Memory information
                    hexCount <= 0;
                end else if (char == "^") stateNext <= s1;
                else stateNext <= init;
            end
            s10: begin
                if (char == " ") stateNext <= s10;
                else if (char == "<") stateNext <= s11;
                else if (char == "^") stateNext <= s1;
                else stateNext <= init;
            end
            s11: begin
                if (char == "=") stateNext <= s12;
                else if (char == "^") stateNext <= s1;
                else stateNext <= init;
            end
            s12: begin
                if (char == " ") stateNext <= s12;
                else if (hexdigit) begin
                    stateNext <= s13;
                    hexCount <= 1;
                end else if (char == "^") stateNext <= s1;
                else stateNext <= init;
            end
            s13: begin
                if (hexdigit && hexCount < 8) hexCount <= hexCount + 1;
                else if (char == "#" && hexCount == 8) begin
                    stateNext <= s14;
                    hexCount <= 0;
                end else if (char == "^") stateNext <= s1;
                else stateNext <= init;
            end
            s14: begin
                if (char == "^") stateNext <= s1;
                else stateNext <= init;
            end
        endcase
    end

    // Output logic
    always @(*) begin
        if (stateNext == s14) 
            format_type = (typeState == 0) ? 2'b01 : 2'b10;
        else 
            format_type = 2'b00;                  
    end

endmodule