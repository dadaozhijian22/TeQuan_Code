`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company		: 
// Engineer		: 特权 franchises3
// Create Date	: 2009.05.12
// Design Name	: 
// Module Name	: datagene
// Project Name	: uartfifo
// Target Device: Cyclone EP1C3T144C8 
// Tool versions: Quartus II 8.1
// Description	: 232发送数据产生模块
//				
// Revision		: V1.0
// Additional Comments	:  
// 
////////////////////////////////////////////////////////////////////////////////
module datagene(
				clk,rst_n,
				wrf_din,wrf_wrreq
			);

input clk;		//FPAG输入时钟信号25MHz
input rst_n;	//FPGA输入复位信号

	//wrFIFO输入控制接口
output[7:0] wrf_din;		//数据写入缓存FIFO输入数据总线
output wrf_wrreq;			//数据写入缓存FIFO数据输入请求，高有效


//------------------------------------------
//每1s写入16个8bit数据到fifo中
reg[24:0] cntwr;	//写sdram定时计数器

always @(posedge clk or negedge rst_n)
	if(!rst_n) cntwr <= 25'd0;
	else cntwr <= cntwr+1'b1;

assign wrf_wrreq = (cntwr >= 25'h1fffff0) && (cntwr <= 25'h1ffffff);	//FIFO写有效信号

//------------------------------------------
//写fifo请求信号产生，即wrfifo的写入有效信号
reg[7:0] wrf_dinr;	//wrfifo的写入数据

always @(posedge clk or negedge rst_n)
	if(!rst_n) wrf_dinr <= 8'd0;
	else if((cntwr >= 25'h1fffff0) && (cntwr <= 25'h1ffffff))
		wrf_dinr <= wrf_dinr+1'b1;	//写入数据递增

assign wrf_din = wrf_dinr;

endmodule
