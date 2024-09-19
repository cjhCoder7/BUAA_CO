module code(
    input Clk,
    input Reset,
    input Slt,                             // select value
    input En,
    output reg [63:0] Output0,             // counter0 value
    output reg [63:0] Output1              // counter1 value
    );

    reg [2:0] validCounter1;

    initial begin
        Output0 <= 64'd0;
        Output1 <= 64'd0;
        validCounter1 <= 3'd0;
    end


    always@(posedge Clk) begin
        if(Reset) begin                    // 如果复位信号有效，则将两个计数器同时清零；
            Output0 <= 64'd0;
            Output1 <= 64'd0;
            validCounter1 <= 3'd0;
        end
        else if(En) begin                 // 如果使能信号有效
            if(Slt == 0)                  // 选择第一个计数器进行操作
                Output0 <= Output0 + 64'd1;
            else                          // 选择第二个计数器进行操作
                validCounter1 <= validCounter1 + 3'd1;
                if(validCounter1 == 3'd3) begin
                    Output1 <= Output1 + 64'd1;
                    validCounter1 <= 3'd0;
                end
        end
    end


endmodule