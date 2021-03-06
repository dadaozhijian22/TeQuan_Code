`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:    
// Design Name:    
// Module Name:    
// Project Name:   
// Target Device:  
// Tool versions:  
// Description:
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 欢迎加入EDN的FPGA/CPLD助学小组一起讨论：http://group.ednchina.com/1375/
////////////////////////////////////////////////////////////////////////////////
module clkdiv(
			clk,rst_n,
			clk_div	
		);

input clk;		//50MHz
input rst_n;	//低电平复位信号

output clk_div;	//分频信号，连接到蜂鸣器

//---------------------------------------------------
reg[19:0] cnt;	//分频计数器

always @ (posedge clk or negedge rst_n)	//异步复位
	if(!rst_n) cnt <= 20'd0;
	else cnt <= cnt+1'b1;	//寄存器cnt 20ms循环计数

//----------------------------------------------------
reg clk_div_r;	//clk_div信号值寄存器

always @ (posedge clk or negedge rst_n) 
	if(!rst_n) clk_div_r <= 1'b0;
	else if(cnt == 20'hfffff) clk_div_r <= ~clk_div_r;	//每20ms让clk_div_r值翻转一次

assign clk_div = clk_div_r;	

endmodule

