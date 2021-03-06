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
module vga_dis(
			clk,rst_n,
			hsync,vsync,
			vga_r,vga_g,vga_b
		);

input clk;		//50MHz
input rst_n;	//低电平复位
output hsync;	//行同步信号
output vsync;	//场同步信号
output vga_r;
output vga_g;
output vga_b;

//--------------------------------------------------
reg[10:0] x_cnt;	//行坐标
reg[9:0] y_cnt;	//列坐标

always @ (posedge clk or negedge rst_n)
	if(!rst_n) x_cnt <= 11'd0;
	else if(x_cnt == 11'd1039) x_cnt <= 11'd0;
	else x_cnt <= x_cnt+1'b1;

always @ (posedge clk or negedge rst_n)
	if(!rst_n) y_cnt <= 10'd0;
	else if(y_cnt == 10'd665) y_cnt <= 10'd0;
	else if(x_cnt == 11'd1039) y_cnt <= y_cnt+1'b1;

//--------------------------------------------------
wire valid;	//有效显示区标志

assign valid = (x_cnt >= 11'd187) && (x_cnt < 11'd987) 
					&& (y_cnt >= 10'd31) && (y_cnt < 10'd631); 

wire[9:0] xpos,ypos;	//有效显示区坐标

assign xpos = x_cnt-11'd187;
assign ypos = y_cnt-10'd31;

//--------------------------------------------------
reg hsync_r,vsync_r;	//同步信号产生

always @ (posedge clk or negedge rst_n)
	if(!rst_n) hsync_r <= 1'b1;
	else if(x_cnt == 11'd0) hsync_r <= 1'b0;	//产生hsync信号
	else if(x_cnt == 11'd120) hsync_r <= 1'b1;
 
always @ (posedge clk or negedge rst_n)
	if(!rst_n) vsync_r <= 1'b1;
	else if(y_cnt == 10'd0) vsync_r <= 1'b0;	//产生vsync信号
	else if(y_cnt == 10'd6) vsync_r <= 1'b1;

assign hsync = hsync_r;
assign vsync = vsync_r;

//--------------------------------------------------
	//显示一个矩形框
wire a_dis,b_dis,c_dis,d_dis;	//矩形框显示区域定位

assign a_dis = ( (xpos>=200) && (xpos<=220) ) 
				&&	( (ypos>=140) && (ypos<=460) );
				
assign b_dis = ( (xpos>=580) && (xpos<=600) )
				&& ( (ypos>=140) && (ypos<=460) );

assign c_dis = ( (xpos>=220) && (xpos<=580) ) 
				&&	( (ypos>140)  && (ypos<=160) );
				
assign d_dis = ( (xpos>=220) && (xpos<=580) )
				&& ( (ypos>=440) && (ypos<=460) );

	//显示一个小矩形
wire e_rdy;	//矩形的显示有效矩形区域

assign e_rdy = ( (xpos>=385) && (xpos<=415) )
				&&	( (ypos>=285) && (ypos<=315) );

//-------------------------------------------------- 
	//r,g,b控制液晶屏颜色显示，背景显示蓝色，矩形框显示红蓝色
assign vga_r = valid ? e_rdy : 1'b0;
assign vga_g = valid ?  (a_dis | b_dis | c_dis | d_dis) : 1'b0;
assign vga_b = valid ? ~(a_dis | b_dis | c_dis | d_dis) : 1'b0;	  

endmodule
