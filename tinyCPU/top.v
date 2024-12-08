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
    //初始赋值
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

    // ROM例化
    dist_mem_im U_IM (
    .a(rom_addr),  // ROM地址输入
    .spo(instr)    // ROM输出的新指令
);
    seg7x16 greedy_snake(.clk(clk),.rstn(rstn),.display_mode(sw_i[0]),.i_data(display_data),.o_seg(disp_seg_o),.o_sel(disp_an_o)); //0号开关控制显示模式
    RegisterFile myRegisterFile(.clk(Clk_CPU),.reset(rstn),.RegisterFileWrite(sw_i[3]))
endmodule


