`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/08 09:24:16
// Design Name: 
// Module Name: registerFile
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


//RegisterFile
module RegisterFile(
    input clk,
    input reset,
    input RegisterFileWrite,
    input [15:0] sw_i,
    input [4:0] A1, A2, A3,
    input [31:0] WriteData,
    output reg [31:0] RD1, RD2
);
endmodule