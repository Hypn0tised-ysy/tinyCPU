`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/24 08:55:33
// Design Name: 
// Module Name: top
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



module top(
    input clk,         // Clock input
    input rstn,        // Reset input
    input [15:0] sw_i, 
    input BTNC,
    input BTNU,
    output [7:0] disp_seg_o, // 输出到7段显示器的信号
    output [7:0] disp_an_o,  // 选择信号
    output [15:0] led_o
    );

    //clk
    reg [31:0] clk_cnt;
    reg [31:0] cpu_clk_cnt;
    wire Clk_CPU;

    //24分频
    parameter div_num=24;
    wire clk_div_24;
    wire clk_div_25;
        always @(posedge clk or negedge rstn) begin
        if (!rstn)
            cpu_clk_cnt <= 32'b0;
        else if(~sw_i[1])
            cpu_clk_cnt <= clk_cnt + 1'b1;
    end
        always @(posedge clk or negedge rstn) begin
        if (!rstn)
            clk_cnt <= 32'b0;
        else
            clk_cnt <= clk_cnt + 1'b1;
    end

    assign Clk_CPU=(sw_i[15])?cpu_clk_cnt[27]:cpu_clk_cnt[25];//15号开关控制分频，开关置1为低频
    assign clk_div_24=clk_cnt[div_num];
    assign clk_div_25=clk_cnt[25];
    reg [63:0]display_data;
    reg [63:0] LED_DATA[18:0];
    wire [63:0] fixed_data = 64'b0000_0000_0000_0000_0111_0110_0101_0100_0011_0010_0001_0000;

initial begin
  LED_DATA[0] = 64'hFF_FF_FF_FE_FE_FE_FE_FE;
  LED_DATA[1] = 64'hFF_FE_FE_FE_FE_FE_FF_FF;    
  LED_DATA[2] = 64'hDE_FE_FE_FE_FF_FF_FF_FF;    
  LED_DATA[3] = 64'hCF_FE_FE_FF_FF_FF_FF_FF;    
  LED_DATA[4] = 64'hC2_FF_FF_FF_FF_FF_FF_FF;    
  LED_DATA[5] = 64'hC1_FE_FF_FF_FF_FF_FF_FF;   
  LED_DATA[6] = 64'hF1_FC_FF_FF_FF_FF_FF_FF;    
  LED_DATA[7] = 64'hFD_F8_F7_FF_FF_FF_FF_FF;
  LED_DATA[8] = 64'hFF_F8_F3_FF_FF_FF_FF_FF;
  LED_DATA[9] = 64'hFF_FB_F1_FE_FF_FF_FF_FF;
  LED_DATA[10] = 64'hFF_FF_F9_F8_FF_FF_FF_FF;
  LED_DATA[11] = 64'hFF_FF_FD_F8_F7_FF_FF_FF;
  LED_DATA[12] = 64'hFF_FF_FF_F9_F1_FF_FF_FF;
  LED_DATA[13] = 64'hFF_FF_FF_FF_F1_FC_FF_FF;  
  LED_DATA[14] = 64'hFF_FF_FF_FF_F9_F8_FF_FF;
  LED_DATA[15] = 64'hFF_FF_FF_FF_FF_F8_F3_FF;
 end 

    reg [5:0] led_data_addr=5'b0;
    reg [63:0] led_disp_data;
    parameter DATA_NUM=16;

   // 产生LED_DATA
reg [5:0] rom_addr; // 6-bit ROM address

always @(posedge Clk_CPU or negedge rstn) begin
    if (!rstn)
        rom_addr <= 6'd0;
    else
    if(sw_i[1]==1'b0)begin
        rom_addr <= rom_addr + 1'b1; // Increment address to fetch next instruction
    end
    else begin
        rom_addr<=rom_addr;
        end
end

always @(posedge clk_div_25 or negedge rstn) begin
    if (!rstn) begin
        led_data_addr <= 6'd0;
        led_disp_data <= 64'b1;
    end else if (sw_i[0] == 1'b1) begin
        if (led_data_addr == DATA_NUM) begin
            led_data_addr <= 6'd0;
            led_disp_data <= 64'b1;
        end else begin
            led_disp_data <= LED_DATA[led_data_addr];
            led_data_addr <= led_data_addr + 1'b1;
        end
    end else begin
        led_data_addr <= led_data_addr;
    end
end

wire [31:0] instruction;
reg [31:0] reg_data; // regvalue
reg [31:0] alu_disp_data;
reg [31:0] dmem_data;

//instruciton
wire [6:0] op;
wire [6:0] func7;
wire [2:0] func3;
wire [4:0] rs1;
wire [4:0] rs2;
wire [4:0] rd;
wire [11:0]load_immediate;
wire [11:0]save_immediate;

wire regWrite;
wire memWrite;
wire [5:0]EXTOp;
wire [4:0]ALUOp;
wire ALUSrc;
wire [2:0]dataMemoryType;
wire writeDataSelection;

wire [31:0]immediate;

wire [31:0] rs1_data;
wire [31:0] rs2_data;

wire signed[31:0] aluOutput;
wire Zero;

wire [31:0]dataMemory_dataOut;

assign led_o[0]=writeDataSelection;
assign led_o[1]=regWrite;
assign led_o[2]=memWrite;
assign led_o[3]=dataMemoryType[0];
assign led_o[4]=dataMemoryType[1];
assign led_o[5]=dataMemoryType[2];
assign led_o[6]=rs2[0];
assign led_o[7]=rs2[1];
assign led_o[15]=Clk_CPU;

// ROM例化
dist_mem_im U_IM (
.a(rom_addr), 
.spo(instruction)   
);

decode decoder(.instruction(instruction),.op(op),.func7(func7),.func3(func3),.rs1(rs1),.rs2(rs2),.rd(rd),.load_immediate(load_immediate),.save_immediate(save_immediate));

control control_signal(.Op(op),.Funct7(func7),.Funct3(func3),.zero(zero),.regWrite(regWrite),.memWrite(memWrite),.EXTOp(EXTOp),.ALUOp(ALUOp),.ALUSrc(ALUSrc),.dataMemoryType(dataMemoryType),.writeDataSelection(writeDataSelection));

immediate_generate gen(.i_immediate(instruction[31:20]),.s_immediate({instruction[31:25],instruction[11:7]}),.b_immediate({instruction[31],instruction[7],instruction[30:25],instruction[11:8]}),.EXTOp(EXTOp),.immediate(immediate));



// choose display source data
always @(sw_i) begin
    if (sw_i[0] == 0) begin
        case (sw_i[14:11])
            4'b1000: display_data = instruction;       // ROM
            4'b0100: display_data = reg_data;    // RF
            4'b0010: display_data = alu_disp_data;
            4'b0001: display_data = dmem_data;
            default: display_data = instruction;
        endcase
    end else begin
        display_data = led_disp_data;
    end
end

//register file
wire[31:0]WriteData;
reg [4:0]reg_address=5'b0;

assign WriteData=writeDataSelection?dataMemory_dataOut:aluOutput;

RegisterFile myRegisterFile(
    .clk(Clk_CPU),
    .reset(rstn),
    .RegisterFileWrite(regWrite),
    .sw_i(sw_i),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .WriteData(WriteData),
    .rs1_data(rs1_data),
    .rs2_data(rs2_data)
);

//register_data
always@ (posedge clk_div_25 or negedge rstn or posedge BTNC) begin
    if(!rstn | BTNC) begin
        reg_address<=5'b0;
        reg_data<=32'b0;
    end
    else if(sw_i[13]==1'b1)begin
        reg_address<=reg_address+1'b1;
        reg_data<=myRegisterFile.register[reg_address];
    end
end

//alu
wire [31:0] operandA,operandB;
reg [2:0] alu_address=3'b0;

        assign operandA=rs1_data;
        assign operandB=(ALUSrc)?immediate:rs2_data;

alu myAlu(
    .operandA(operandA),
    .operandB(operandB),
    .ALUOp(ALUOp),
    .result(aluOutput),
    .Zero(Zero)
);

always@(posedge clk_div_25 or negedge rstn) begin
    if(!rstn)
        alu_address<=3'b0;
    begin 
        alu_address<=alu_address+1'b1;
        case(alu_address)
        3'b001:alu_disp_data=myAlu.operandA;
        3'b010:alu_disp_data=myAlu.operandB;
        3'b011:alu_disp_data=myAlu.result;
        3'b100:alu_disp_data=Zero;
        default:alu_disp_data=32'hFFFFFFFF;
        endcase
    end
end

//data memory
reg [31:0]display_memory_address;
wire [31:0]dataMemory_dataIn;
parameter DM_DATA_NUM=16;


dataMemory myDataMemory(
    .clk(Clk_CPU),
    .rstn(rstn),
    .dataMemoryWrite(memWrite&~sw_i[1]),
    .address(aluOutput[5:0]),
    .dataIn(rs2_data),
    .dataMemoryType(dataMemoryType),
    .dataOut(dataMemory_dataOut)
);

always@(posedge clk_div_25 or negedge rstn or posedge BTNU) begin
    if(!rstn|BTNU)begin
        display_memory_address<=6'b0;
        dmem_data=32'hFFFFFFFF;
    end
    else if(sw_i[11]==1'b1)begin
        display_memory_address<=display_memory_address+1'b1;
        dmem_data=myDataMemory.data[display_memory_address][7:0];
        dmem_data={display_memory_address,dmem_data[27:0]};
        if(display_memory_address==DM_DATA_NUM)begin   
            display_memory_address=6'b0;
            dmem_data=32'hFFFFFFFF;
        end
    end
end

    seg7x16 greedy_snake(.clk(clk),.rstn(rstn),.display_mode(sw_i[0]),.i_data(display_data),.o_seg(disp_seg_o),.o_sel(disp_an_o)); //0号开关控制显示模式
    

endmodule