`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/31 21:13:53
// Design Name: 
// Module Name: fs_cap
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


module fs_cap(
    input  clk_i,
    input  rstn_i,
    input  vs_i,
    input  s_rdy_i,
    output reg fs_cap_o
    );
    
//----CH0_CNT_FS信号电平计数 实际就是采样VS信号----------------
    reg[4:0]CNT_FS   = 6'b0;
    reg[4:0]CNT_FS_n = 6'b0;
    reg     FS       = 1'b0;
    reg[3:0]FS_TEM   =4'd0;
//----同步整形电路，之前大意没加整形电路导致总是采集vs出错-----
    always@(posedge clk_i) begin
        if(!rstn_i)begin
            FS_TEM <= 4'hf;
        end
        else begin
            FS_TEM <= {FS_TEM[3:0],vs_i};
        end
    end
     
    always@(posedge clk_i)begin
         if(!rstn_i) begin    
            CNT_FS    <= 5'd0;
            CNT_FS_n  <= 5'd0;
         end
         else if(FS_TEM[3]) begin
            CNT_FS   <= (CNT_FS <5'd30)? (CNT_FS+5'd1):5'd30;
            CNT_FS_n <= 5'd0;
         end
         else if(!FS_TEM[3])begin
            CNT_FS_n <= (CNT_FS_n <5'd30)?(CNT_FS_n+5'd1):5'd30;
            CNT_FS   <= 5'd0;
         end
    end
    
    always@(posedge clk_i) begin
         if(!rstn_i)begin
            FS <= 1'b1;
         end
         else if( CNT_FS  >= 5'd20)begin
            FS <= 1'b1;
         end
         else if( CNT_FS_n >= 5'd20)begin
            FS <= 1'b0;
         end
    end
    
    reg FS_r = 1'b0;
    always@(posedge clk_i) begin
         FS_r <= (!rstn_i) ?  1'b1 : FS; 
    end
    
    always@(posedge clk_i) begin
         if(!rstn_i)begin
            fs_cap_o <= 1'd0;
         end
         else if({FS_r,FS} == 2'b01 && s_rdy_i == 1'b1 && fs_cap_o == 1'b0)begin
            fs_cap_o <= 1'b1;
         end
         else begin
            fs_cap_o <= 1'b0;
         end
    end
        
endmodule

