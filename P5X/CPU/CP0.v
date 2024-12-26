`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:16:58 11/05/2024 
// Design Name: 
// Module Name:    CP0 
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
module CP0(
    input Clk,  // 时钟信号
    input Reset,    // 复位信号
    input En,       // 写使能信号
    input [4:0] CP0Add,     // 寄存器地址
    input [31:0] CP0In,     // CP0 写入数据
    output reg [31:0] CP0Out,   // CP0 读出数据
    input [31:0] VPC,       // 受害PC
    input [4:0] ExcCodeIn,  // 记录异常类型
    input EXLClr,           // 用来复位EXL
    output [31:0] EPCOut,   // EPC的值
    output Req              // 进入处理程序的请求
    );

    reg [31:0] SR;          // 编号12,状态寄存器 R/W, 配置异常的功能。
    reg [31:0] Cause;       // 编号13,导致异常或者是中断的原因
    reg [31:0] EPC;         // 编号14,记录异常处理结束后需要返回的PC。

    initial begin
        SR = 32'h0;
        Cause = 32'h0;
        EPC = 32'h0;
        CP0Out = 32'h0;
    end

    always @(posedge Clk) begin
        if (Reset) begin
            SR <= 32'h0;
            Cause <= 32'h0;
            EPC <= 32'h0;
        end else begin
            // 写入操作
            if (En) begin
                case (CP0Add)
                    5'd12: SR <= CP0In;        // 写入 SR 寄存器
                    5'd13: Cause <= CP0In;     // 写入 Cause 寄存器
                    5'd14: EPC <= CP0In;       // 写入 EPC 寄存器
                    default: ;
                endcase
            end
            
            // EXLClr 信号清除 SR[1] 位
            if (EXLClr) begin
                SR[1] <= 1'b0;
            end

            if ((ExcCodeIn != 5'b00000) && (SR[1] == 0)) begin
                Cause[6:2] <= ExcCodeIn;      // 记录异常类型
                EPC <= VPC;                   // 若 EXL 位为 0，保存受害 PC
                SR[1] <= 1'b1;                // 设置 EXL 位          
            end
        end
    end

    // 读操作
    always @(*) begin
        case (CP0Add)
            5'd12: CP0Out = SR;
            5'd13: CP0Out = Cause;
            5'd14: CP0Out = EPC;
            default: CP0Out = 32'h0;
        endcase
    end

    // EPC 输出
    assign EPCOut = EPC;

    assign Req = (ExcCodeIn != 5'b00000) && (SR[1] == 0);

endmodule
