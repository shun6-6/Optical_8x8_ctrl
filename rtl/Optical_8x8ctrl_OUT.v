`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/01 13:59:15
// Design Name: 
// Module Name: Optical_8x8_OUT
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


module Optical_8x8ctrl_OUT#(
    parameter       P_BAR       =   1'b0,
    parameter       P_CROSS     =   1'b1,
    parameter       P_DSTWIDTH  =   3   ,
    parameter       P_PORTNUM   =   8   ,
    parameter       P_SWITCHNUM =   4      
)(
    input                                   i_clk           ,
    input                                   i_rst           ,

    input  [P_DSTWIDTH*P_PORTNUM - 1:0]     i_8x8out_req    ,
    input                                   i_8x8out_valid  ,
    output [P_SWITCHNUM - 1:0]              o_switch_grant  ,
    output                                  o_grant_valid   ,

    input                                   i_config_end             
);
/***************function**************/

/***************parameter*************/

/***************port******************/             

/***************mechine***************/

/***************reg*******************/
reg  [P_DSTWIDTH*P_PORTNUM - 1:0]   ri_8x8out_req   ;
reg                                 ri_8x8out_valid ;
reg  [P_SWITCHNUM - 1:0]            ro_switch_grant ;
reg                                 ro_grant_valid  ;
/***************wire******************/

/***************component*************/

/***************assign****************/
assign o_switch_grant = ro_switch_grant;
assign o_grant_valid  = ro_grant_valid ;
/***************always****************/
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
        ri_8x8out_req   <= 'd0;
        ri_8x8out_valid <= 'd0;
    end
    else begin
        ri_8x8out_req   <= i_8x8out_req  ;
        ri_8x8out_valid <= i_8x8out_valid;        
    end
end

genvar i;
generate
    for(i = 0 ; i < P_SWITCHNUM ; i = i + 1)begin
        always @(posedge i_clk or posedge i_rst)begin
            if(i_rst)
                ro_switch_grant[i] <= 'd0;
            else if(ri_8x8out_valid && (ri_8x8out_req[3*2*i +: 3] == (2*i)))
                ro_switch_grant[i] <= P_BAR;
            else
                ro_switch_grant[i] <= P_CROSS;
        end
    end
endgenerate

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_grant_valid <= 'd0;
    else if(i_config_end)
        ro_grant_valid <= 'd0;
    else if(ri_8x8out_valid)
        ro_grant_valid <= 'd1;    
    else
        ro_grant_valid <= 'd0;
end

endmodule
