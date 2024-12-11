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
    output [7:0] disp_seg_o, // 输出到7段显示器的信号
    output [7:0] disp_an_o  // 选择信号
    );

    //clk
    reg [31:0] clk_cnt;
    wire Clk_CPU;

    //24分频
    parameter div_num=24;
    wire clk_div_24;
        always @(posedge clk or negedge rstn) begin
        if (!rstn)
            clk_cnt <= 32'b0;
        else
            clk_cnt <= clk_cnt + 1'b1;
    end

    assign Clk_CPU=(sw_i[15])?clk_cnt[27]:clk_cnt[25];//15号开关控制分频，开关置1为低频
    assign clk_div_24=clk_cnt[div_num];
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
        rom_addr <= rom_addr + 1'b1; // Increment address to fetch next instruction
end

always @(posedge Clk_CPU or negedge rstn) begin
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

wire [31:0] instr;
reg [31:0] reg_data; // regvalue
reg [31:0] alu_disp_data;
reg [31:0] dmem_data;

// choose display source data
always @(sw_i) begin
    if (sw_i[0] == 0) begin
        case (sw_i[14:11])
            4'b1000: display_data = instr;       // ROM
            4'b0100: display_data = reg_data;    // RF
            4'b0010: display_data = alu_disp_data;
            4'b0001: display_data = dmem_data;
            default: display_data = instr;
        endcase
    end else begin
        display_data = led_disp_data;
    end
end

//register file
wire RegisterFileWrite=sw_i[2];
wire[31:0]WriteData={sw_i[8],28'b0,sw_i[7:5]};//原码表示，register中存储补码，方便人类操作
wire[4:0]rd=sw_i[10:9];//牺牲一位寄存器选择来作为writeData的符号位
wire[4:0]rs1=5'b0;//to be modified
wire[4:0]rs2=5'b0;//to be modified
reg [4:0]reg_address=5'b0;
assign RegisterFileWrite=sw_i[2];
assign WriteData={sw_i[8],28'b0,sw_i[7:5]};//sw_i[8]作为符号位，和文档不一样，注意
assign rd=sw_i[10:9];

//register_data
always@ (posedge Clk_CPU or negedge rstn) begin
    if(!rstn) begin
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
wire [4:0] ALUOp={3'b0,sw_i[4:3]};
reg [2:0] alu_address=3'b0;
assign operandA=myRegisterFile.register[sw_i[10:8]];
assign operandB=myRegisterFile.register[sw_i[7:5]];

always@(posedge Clk_CPU or negedge rstn) begin
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
wire [2:0]memory_address;
wire [31:0]dataMemory_dataIn;
wire [31:0]dataMemory_dataOut;
wire [1:0]dataMemoryType;
parameter DM_DATA_NUM=16;

assign memory_address=sw_i[10:8];
assign dataMemory_dataIn=sw_i[7:5];
assign dataMemoryType=sw_i[4:3];

always@(posedge Clk_CPU or negedge rstn) begin
    if(!rstn)begin
        display_memory_address=6'b0;
        dmem_data=32'hFFFFFFFF;
    end
    if(sw_i[11]==1'b1)begin
        display_memory_address=display_memory_address+1'b1;
        dmem_data=myDataMemory.data[display_memory_address][7:0];
        dmem_data={display_memory_address,dmem_data[27:0]};
        if(display_memory_address==DM_DATA_NUM)begin   
            display_memory_address=6'b0;
            dmem_data=32'hFFFFFFFF;
        end
    end
end

    // ROM例化
    dist_mem_im U_IM (
    .a(rom_addr),  // ROM地址输入
    .spo(instr)    // ROM输出的新指令
);

RegisterFile myRegisterFile(
    .clk(Clk_CPU),
    .reset(rstn),
    .RegisterFileWrite(RegisterFileWrite),
    .sw_i(sw_i),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .WriteData(WriteData),
    .rs1_data(rs1_data),
    .rs2_data(rs2_data)
);
alu myAlu(
    .operandA(operandA),
    .operandB(operandB),
    .ALUOp(ALUOp),
    .result(aluOutput),
    .Zero(Zero)
);
dataMemory myDataMemory(
    .clk(Clk_CPU),
    .dataMemoryWrite(sw_i[2]&&!sw_i[1]),
    .address({3'b0,memory_address[2:0]}),
    .dataIn(dataMemory_dataIn),
    .dataMemoryType(dataMemoryType[1:0]),
    .dataOut(dataMemory_dataOut)
);
    seg7x16 greedy_snake(.clk(clk),.rstn(rstn),.display_mode(sw_i[0]),.i_data(display_data),.o_seg(disp_seg_o),.o_sel(disp_an_o)); //0号开关控制显示模式

endmodule








