`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/12 14:35:56
// Design Name: 
// Module Name: decode
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


module decode(
    input [31:0] instruction,  // 输入指令
    output [6:0] op,           // 指令 opcode
    output [6:0] func7,        // func7 字段
    output [2:0] func3,        // func3 字段
    output [4:0] rs1,          // rs1 寄存器编号
    output [4:0] rs2,          // rs2 寄存器编号
    output [4:0] rd,           // rd 寄存器编号
    output [11:0] load_immediate,  // 立即数 (load)
    output [11:0] save_immediate   // 立即数 (save)
);
    // 信号分配
    assign op = instruction[6:0];                         // Opcode
    assign func7 = instruction[31:25];                   // func7
    assign func3 = instruction[14:12];                   // func3
    assign rs1 = instruction[19:15];                     // rs1
    assign rs2 = instruction[24:20];                     // rs2
    assign rd = instruction[11:7];                       // rd
    assign load_immediate = instruction[31:20];          // load immediate
    assign save_immediate = {instruction[31:25], instruction[11:7]};  // save immediate
endmodule
