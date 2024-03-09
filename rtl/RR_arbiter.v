`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/08 16:56:21
// Design Name: 
// Module Name: RR_arbiter
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


module RR_arbiter#(
    parameter       P_CHANNEL_NUM   =   8
)(
    input                           i_clk               ,
    input                           i_rst               ,
    input  [P_CHANNEL_NUM - 1 : 0]  i_req               ,
    //input  [P_CHANNEL_NUM - 1 : 0]  i_first_priority    ,
    input                           i_req_valid         ,
    output [P_CHANNEL_NUM - 1 : 0]  o_grant             ,
    output                          o_grant_valid       ,
    input                           reset_priority
);
/***************function**************/

/***************parameter*************/

/***************port******************/             

/***************mechine***************/

/***************reg*******************/
reg  [P_CHANNEL_NUM - 1 : 0]    ro_grant        ;
reg                             ro_grant_valid  ;

reg  [P_CHANNEL_NUM - 1 : 0]    round_priority  ;
/***************wire******************/
wire [2*P_CHANNEL_NUM - 1 : 0]  req_sub_first_priority  ;
wire [2*P_CHANNEL_NUM - 1 : 0]  w_double_req    ;
wire [2*P_CHANNEL_NUM - 1 : 0]  w_double_grant  ;
/***************component*************/

/***************assign****************/
assign o_grant  = ro_grant  ;
assign o_grant_valid = ro_grant_valid;
assign req_sub_first_priority = w_double_req - round_priority;
assign w_double_req = {i_req,i_req};
assign w_double_grant = w_double_req & (~req_sub_first_priority);
/***************always****************/
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        round_priority <= 'd1;
    else if(reset_priority)
        round_priority <= 'd1;
    else if(ro_grant_valid)
        round_priority <= {round_priority[P_CHANNEL_NUM - 2 : 0],round_priority[P_CHANNEL_NUM - 1]};
    else
        round_priority <= round_priority;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_grant <= 'd0;
    else if(i_req_valid)
        ro_grant <= w_double_grant[P_CHANNEL_NUM - 1 : 0] | w_double_grant[2*P_CHANNEL_NUM - 1 : P_CHANNEL_NUM];
    else
        ro_grant <= ro_grant;   
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_grant_valid <= 'd0;
    else if(i_req_valid)
        ro_grant_valid <= 1'b1;
    else
        ro_grant_valid <= 'd0;   
end

endmodule
