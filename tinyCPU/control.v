`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/12 14:45:42
// Design Name: 
// Module Name: control
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

module control(
    input [6:0] Op,
    input [6:0] Funct7,
    input [2:0] Funct3,
    input zero,
    output regWrite,
    output memWrite,
    output [5:0] EXTOp,
    output [4:0] ALUOp,
    output ALUSrc,
    output [2:0] dataMemoryType,
    output writeDataSelection // memToReg
);

wire rtype  = ~Op[6]&Op[5]&Op[4]&~Op[3]&~Op[2]&Op[1]&Op[0]; //0110011
wire i_add=rtype&~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&~Funct3[2]&~Funct3[1]&~Funct3[0]; // add 0000000 000
wire i_sub=rtype&~Funct7[6]&Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&~Funct3[2]&~Funct3[1]&~Funct3[0]; // sub 0100000 000

wire itype_l  = ~Op[6]&~Op[5]&~Op[4]&~Op[3]&~Op[2]&Op[1]&Op[0]; //0000011
wire i_lb=itype_l&~Funct3[2]& ~Funct3[1]& ~Funct3[0]; //lb 000
wire i_lh=itype_l&~Funct3[2]& ~Funct3[1]& Funct3[0];  //lh 001
wire i_lw=itype_l&~Funct3[2]& Funct3[1]& ~Funct3[0];  //lw 010

wire itype_r  = ~Op[6]&~Op[5]&Op[4]&~Op[3]&~Op[2]&Op[1]&Op[0]; //0010011
wire i_addi  =  itype_r& ~Funct3[2]& ~Funct3[1]& ~Funct3[0]; // addi 000 func3

wire stype  = ~Op[6]&Op[5]&~Op[4]&~Op[3]&~Op[2]&Op[1]&Op[0]   ;//0100011
wire i_sw   = stype&~Funct3[2]&Funct3[1]&Funct3[0]; // sw 010
wire i_sb=stype& ~Funct3[2]& ~Funct3[1]&~Funct3[0];
wire i_sh=stype&& ~Funct3[2]&~Funct3[1]&Funct3[0];

assign regWrite   = rtype | itype_r|itype_l  ; // register write
assign memWrite   = stype;              // memory write
assign ALUSrc     = itype_r | stype | itype_l ; // ALU B is from instruction immediate
//mem2reg=wdsel ,WDSel_FromALU 2'b00  WDSel_FromMEM 2'b01
assign writeDataSelection = itype_l;   
 // assign WDSel[1] = 1'b0;  

//ALUOp_nop 5'b00000
//ALUOp_lui 5'b00001
//ALUOp_auipc 5'b00010
//ALUOp_add 5'b00011
assign ALUOp[0]= i_add  | i_addi|stype|itype_l ;
assign ALUOp[1]= i_add  | i_addi|stype|itype_l ;
assign ALUOp[2]=0;
assign ALUOp[3]=0;
assign ALUOp[4]=0;

assign EXTOp[0] =  stype;
assign EXTOp[1] =  itype_l | itype_r ; 
assign EXTOp[2]=0;
assign EXTOp[4]=0;
assign EXTOp[5]=0;
//assign EXTOp[5]    =    i_slli | i_srai | i_srli;
//assign EXTOp[4]    =    (itype_l | itype_r) & ~i_slli & ~i_srai & ~i_srli;  
assign EXTOp[3]    =    0; 
//assign EXTOp[2]    =    sbtype; 
//assign EXTOp[1]    =    i_lui | i_auipc;   
//assign EXTOp[0]    =    i_jal;  

// dm_word 3'b000
//dm_halfword 3'b001
//dm_halfword_unsigned 3'b010
//dm_byte 3'b011
//dm_byte_unsigned 3'b100

//assign dataMemoryType[2]=i_lbu;
//assign dataMemoryType[1]=i_lb | i_sb | i_lhu;
assign dataMemoryType[0]=i_lh | i_sh | i_lb | i_sb;


endmodule