`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/10 17:57:21
// Design Name: 
// Module Name: lcd_driver_dualwin
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


module lcd_driver
(  	
	//global clock
	input			clk,			//system clock
	input			rst_n,     		//sync reset
	
	//lcd interface
	output			lcd_hs,	    	//lcd horizontal sync
	output			lcd_vs,	    	//lcd vertical sync
	output			lcd_en,			//lcd display enable
	output	[23:0]	lcd_rgb,		//lcd display data

	//user interface
	output			lcd_request,
	input			framediff_flag,
	input	[23:0]	lcd_gray,
	input	[23:0]	lcd_data		//lcd data
);	 

`include "lcd_para.vh" 

/*******************************************
		SYNC--BACK--DISP--FRONT
*******************************************/
//------------------------------------------
//h_sync counter & generator
reg [11:0] hcnt; 
always @ (posedge clk or negedge rst_n)
begin
	if (!rst_n)
		hcnt <= 12'd0;
	else
		begin
        if(hcnt < `H_TOTAL - 1'b1)		//line over			
            hcnt <= hcnt + 1'b1;
        else
            hcnt <= 12'd0;
		end
end 
assign	lcd_hs = (hcnt <= `H_SYNC - 1'b1) ? 1'b0 : 1'b1;

//------------------------------------------
//v_sync counter & generator
reg [11:0] vcnt;
always@(posedge clk or negedge rst_n)
begin
	if (!rst_n)
		vcnt <= 12'b0;
	else if(hcnt == `H_TOTAL - 1'b1)		//line over
		begin
		if(vcnt < `V_TOTAL - 1'b1)		//frame over
			vcnt <= vcnt + 1'b1;
		else
			vcnt <= 12'd0;
		end
end
assign	lcd_vs = (vcnt <= `V_SYNC - 1'b1) ? 1'b0 : 1'b1;

//-----------------------------------------
assign	lcd_en		=	(hcnt >= `H_SYNC + `H_BACK  && hcnt < `H_SYNC + `H_BACK + `H_DISP) &&
						(vcnt >= `V_SYNC + `V_BACK  && vcnt < `V_SYNC + `V_BACK + `V_DISP) 
						? 1'b1 : 1'b0;

//------------------------------------------
//ahead x clock
localparam	H_AHEAD = 	12'd5;

assign	lcd_request =	(hcnt >= `H_SYNC + `H_BACK - H_AHEAD && hcnt < `H_SYNC + `H_BACK + `H_DISP- H_AHEAD) &&
						(vcnt >= `V_SYNC + `V_BACK  && vcnt < `V_SYNC + `V_BACK + `V_DISP) 
						? 1'b1 : 1'b0;				
						
//lcd xpos & ypos
wire	[11:0]	lcd_xpos;		//lcd horizontal coordinate
wire	[11:0]	lcd_ypos;
assign	lcd_xpos	= 	lcd_request ? (hcnt - (`H_SYNC + `H_BACK - H_AHEAD)) : 12'd0;
assign	lcd_ypos	= 	lcd_request ? (vcnt - (`V_SYNC + `V_BACK)) : 12'd0;

//------------------------边缘追踪--------------------------
wire [11:0] hcount_l;
wire [11:0] hcount_r;
wire [11:0] vcount_l;
wire [11:0] vcount_r;
boundary_tracking u_boundary_tracking
(
	.clk 		(clk), //lcd clock
	.rst_n 		(rst_n),

	.th_value	(lcd_data[7:0]),
	.lcd_vs 	(lcd_vs),
	.hcount_r0 	(lcd_xpos),
	.vcount_r0 	(lcd_ypos),
	.hcount_l 	(hcount_l),
	.hcount_r 	(hcount_r),
	.vcount_l 	(vcount_l),
	.vcount_r 	(vcount_r)
);

localparam RED    = 24'hff0000;     //字符颜色
localparam BLACK  = 24'h000000;
//----------------display-----------------------
reg [23:0]	lcd_rgb;
always @(posedge clk or negedge rst_n)begin
	if(!rst_n) 
		lcd_rgb <= BLACK;
	else if(lcd_en)begin
		if(lcd_ypos > vcount_l && lcd_ypos < vcount_r && ( lcd_xpos == hcount_l || lcd_xpos == hcount_r || lcd_xpos == (hcount_l - 1) || lcd_xpos == (hcount_r + 1)))
			lcd_rgb <= RED;
		else if(lcd_xpos > hcount_l && lcd_xpos < hcount_r && (lcd_ypos == vcount_l || lcd_ypos == vcount_r || lcd_ypos == ( vcount_l - 1) || lcd_ypos == (vcount_r + 1)))
			lcd_rgb <= RED;
		else if(framediff_flag)
			lcd_rgb <= lcd_data;
		else 
			lcd_rgb <= lcd_gray;
	end
	else 
		lcd_rgb <= BLACK;
end

endmodule

