`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/08 09:27:57
// Design Name: 
// Module Name: rom
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


//rom
module SCPU_TOP(
    input clk,          // 100MHZ CLK
    input rstn,         // reset signal
    input [15:0] sw_i,  // sw_i[15] --- sw_i[0]
    output reg [7:0] disp_an_o, // 8位数码管位选
    output reg [7:0] disp_seg_o // 数码管8段数据
);
