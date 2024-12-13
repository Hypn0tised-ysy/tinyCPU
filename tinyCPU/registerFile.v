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
    input [4:0] rs1, rs2, rd,
    input [31:0] WriteData,
    output reg [31:0] rs1_data, rs2_data
);

reg [31:0] register[31:0];
integer  ith_register;

always@(posedge clk or negedge reset) begin
    if(!reset) begin
    for(ith_register = 0; ith_register < 32; ith_register = ith_register + 1) begin
        register[ith_register]=ith_register;
    end
    end
    else if(RegisterFileWrite) begin
        register[rd]<=WriteData;
    end
    rs1_data <= (rs1 == 5'b0) ? 32'b0 : register[rs1];
    rs2_data <= (rs2 == 5'b0) ? 32'b0 : register[rs2];
end

endmodule