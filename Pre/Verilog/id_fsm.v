module id_fsm(
    input clk,                         // Clock signal
    input [7:0] char,                  // Character stream input
    output reg out                     // 1: format right, 0: format wrong
    );

    // Input character checks
    wire digit = (char >= "0" && char <= "9");
    wire alpha = (char >= "a" && char <= "z") || (char >= "A" && char <= "Z");

    // State definitions
    parameter init = 2'd0;
    parameter alpha_state = 2'd1;
    parameter digit_state = 2'd2;

    reg [1:0] state;

    initial begin
        state <= init;
    end

    // State transition logic
    always @(posedge clk) begin
        case (state)
            init: begin
                if (alpha) state <= alpha_state;
                else state <= init;
            end
            alpha_state: begin
                if (digit) state <= digit_state;
                else if (alpha) state <= alpha_state;
                else state <= init;
            end
            digit_state: begin
                if (digit) state <= digit_state;
                else if (alpha) state <= alpha_state;
                else state <= init;
            end
        endcase
    end

    // Output logic
    always @(*) begin
        if(state == digit_state) out = 1;
        else out = 0;
    end

endmodule