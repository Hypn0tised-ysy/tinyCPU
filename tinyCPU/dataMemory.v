`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/11 18:32:19
// Design Name: 
// Module Name: dataMemory
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

`define DM_WORD 3'b000
`define DM_HALFWORD 3'b001
`define DM_HALFWORD_UNSIGNED 3'b010
`define DM_BYTE 3'b011
`define DM_BYTE_UNSIGNED 3'b100

module dataMemory    (
    input clk,
    input dataMemoryWrite,
    input [5:0] address,
    input [31:0] dataIn,
    input [2:0] dataMemoryType,
    output reg[31:0]dataOut
);

reg [7:0]data[31:0];

always@ (posedge clk)begin
    //write
    if(dataMemoryWrite)
    begin
    case(dataMemoryType)
    `DM_BYTE: data[address]<=dataIn[7:0];
    `DM_HALFWORD: begin
        data[address]<=dataIn[7:0];
        data[address+1]<=dataIn[15:8];
    end 
    `DM_WORD: begin 
        data[address]<=dataIn[7:0];
        data[address+1]<=dataIn[15:8];
        data[address+2]<=dataIn[23:16];
        data[address+3]<=dataIn[31:24];
    end
    endcase
    end
//read,using sign extension
else begin
    case(dataMemoryType)
    `DM_BYTE: begin
    dataOut={{24{data[address][7]}}, data[address][7:0]};
    end
    `DM_HALFWORD: begin
        dataOut={data[address+1][7:0],data[address][7:0]};
    end 
    `DM_WORD: begin 
        dataOut={data[address+3][7:0],data[address+2][7:0],data[address+1][7:0],data[address][7:0]};
    end
    endcase
end
end

endmodule
