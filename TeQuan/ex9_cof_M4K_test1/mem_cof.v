`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company		: 
// Engineer		: 特权 franchise.3
// Create Date	: 2009.04.20
// Design Name	: mem_cof
// Module Name	: mem_cof
// Project Name	: mem_cof
// Target Device: Cyclone EP1C3T144C8 
// Tool versions: Quartus II 8.1
// Description	: 配置M4K产生一个256*8bit的单口RAM
//				
// Revision		: V1.0
// Additional Comments	:  
// 欢迎加入EDN的FPGA/CPLD助学小组一起讨论：http://group.ednchina.com/1375/
////////////////////////////////////////////////////////////////////////////////
module mem_cof(
			clk,rst_n,
			ram_wr,ram_addr,ram_din,ram_dout
		);

input clk;		//系统输入时钟，25M
input rst_n;	//系统服务信号，低有效

input ram_wr;			//RAM写入使能信号，高表示写入
input[11:0] ram_addr;	//RAM地址总线

input[7:0]  ram_din;		//RAM写入数据总线
output[7:0] ram_dout;		//RAM读出数据总线


//例化M4K生成的RAM
sys_ram 	uut_ram(
				.address(ram_addr),
				.clock(clk),
				.data(ram_din),
				.wren(ram_wr),
				.q(ram_dout)
			);


endmodule

