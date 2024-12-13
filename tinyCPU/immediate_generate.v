`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/12 14:55:18
// Design Name: 
// Module Name: immediate_generate
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module immediate_generate(
    input [4:0] i_immediate_shift_amount,
    input [11:0] i_immediate,
    input [11:0] s_immediate,
    input [11:0] b_immediate,
    input [19:0] u_immediate,
    input [19:0] j_immediate,
    input [5:0] EXTOp,
    output reg[31:0] immediate
    );

        always @(*) begin
        case (EXTOp)
            6'b000010: // `EXT_CTRL_ITYPE
                immediate <= {{20{i_immediate[11]}}, i_immediate[11:0]}; // 符号扩展
            6'b000001: // `EXT_CTRL_STYPE
                immediate <= {{20{s_immediate[11]}}, s_immediate[11:0]}; // 符号扩展
            6'b000100: // `EXT_CTRL_BTYPE
                immediate <= {{19{b_immediate[11]}}, b_immediate[11:0], 1'b0}; // 符号扩展并左移1位
            6'b000101: // `EXT_CTRL_UTYPE
                immediate <= {u_immediate[19:0], 12'b0}; // U型指令的高位立即数，补零扩展
            6'b000110: // `EXT_CTRL_JTYPE
                immediate <= {{11{j_immediate[19]}}, j_immediate[19:0], 1'b0}; // 符号扩展并左移1位
            default:
                immediate <= 32'b0; // 默认情况下为零
        endcase
    end
endmodule
