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
module sram_test(
				clk,rst_n,led,
				sram_addr,sram_wr_n,sram_data
			);

input clk;		// 50MHz
input rst_n;	//低电平复位
output led;		// LED1

	// CPLD与SRAM外部接口
output[14:0] sram_addr;	// SRAM地址总线
output sram_wr_n;		// SRAM写选通
inout[7:0] sram_data;	// SRAM数据总线

//-------------------------------------------------------
reg[25:0] delay;	//延时计数器

always @ (posedge clk or negedge rst_n)
	if(!rst_n) delay <= 26'd0;
	else delay <= delay+1;	//不断计数，周期约为1.28s
	
//-------------------------------------------------------
reg[7:0] wr_data;	// SRAM写入数据总线	
reg[7:0] rd_data;	// SRAM读出数据 
reg[14:0] addr_r;	// SRAM地址总线
wire sram_wr_req;	// SRAM写请求信号
wire sram_rd_req;	// SRAM读请求信号
reg led_r;			// LED寄存器

assign sram_wr_req = (delay == 26'd9999);	//产生写请求信号
assign sram_rd_req = (delay == 26'd19999);	//产生读请求信号
	
always @ (posedge clk or negedge rst_n)
	if(!rst_n) wr_data <= 8'd0;
	else if(delay == 26'd29999) wr_data <= wr_data+1'b1;	//写入数据每1.28s自增1
always @ (posedge clk or negedge rst_n)
	if(!rst_n) addr_r <= 15'd0;
	else if(delay == 26'd29999) addr_r <= addr_r+1'b1;	//写入地址每1.28s自增1
	
always @ (posedge clk or negedge rst_n)
	if(!rst_n) led_r <= 1'b0;
	else if(delay == 26'd20099) begin	//每1.28s比较一次同一地址写入和读出的数据
			if(wr_data == rd_data) led_r <= 1'b1;	//写入和读出数据一致，LED点亮
			else led_r <= 1'b0;						//写入和读出数据不同，LED熄灭
		end
assign led = led_r;

//-------------------------------------------------------
`define	DELAY_80NS		(cnt==3'd7)

reg[2:0] cnt;	//延时计数器

always @ (posedge clk or negedge rst_n)
	if(!rst_n) cnt <= 3'd0;
	else if(cstate == IDLE) cnt <= 3'd0;
	else cnt <= cnt+1'b1;
			
//------------------------------------
parameter	IDLE	= 4'd0,
			WRT0	= 4'd1,
			WRT1	= 4'd2,
			REA0	= 4'd3,
			REA1	= 4'd4;

reg[3:0] cstate,nstate;

always @ (posedge clk or negedge rst_n)
	if(!rst_n) cstate <= IDLE;
	else cstate <= nstate;

always @ (cstate or sram_wr_req or sram_rd_req or cnt)
	case (cstate)
			IDLE: if(sram_wr_req) nstate <= WRT0;		//进入写状态
				  else if(sram_rd_req) nstate <= REA0;	//进入读状态
				  else nstate <= IDLE;
			WRT0: if(`DELAY_80NS) nstate <= WRT1;
				  else nstate <= WRT0;				//延时等待160ns	
			WRT1: nstate <= IDLE;			//写结束，返回
			REA0: if(`DELAY_80NS) nstate <= REA1;
				  else nstate <= REA0;				//延时等待160ns
			REA1: nstate <= IDLE;			//读结束，返回
		default: nstate <= IDLE;
		endcase
			
//-------------------------------------

assign sram_addr = addr_r;	// SRAM地址总线连接

//-------------------------------------			
reg sdlink;				// SRAM数据总线控制信号

always @ (posedge clk or negedge rst_n)
	if(!rst_n) rd_data <= 8'd0;
	else if(cstate == REA1) rd_data <= sram_data;		//读出数据

always @ (posedge clk or negedge rst_n)
	if(!rst_n) sdlink <=1'b0;
	else
		case (cstate)
			IDLE: if(sram_wr_req) sdlink <= 1'b1;		//进入连续写状态
				  else if(sram_rd_req) sdlink <= 1'b0;	//进入单字节读状态
				  else sdlink <= 1'b0;
			WRT0: sdlink <= 1'b1;
			default: sdlink <= 1'b0;
			endcase

assign sram_data = sdlink ? wr_data : 8'hzz;	// SRAM地址总线连接			
assign sram_wr_n = ~sdlink;
			
endmodule
