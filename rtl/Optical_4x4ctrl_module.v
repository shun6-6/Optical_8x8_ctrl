`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/01 09:49:49
// Design Name: 
// Module Name: Optical_4x4_module
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


module Optical_4x4ctrl_module#(
    parameter       P_BAR   =   1'b0,
    parameter       P_CROSS =   1'b1   
)(
    input           i_clk           ,
    input           i_rst           ,

    input  [7 :0]   i_4x4_req       ,
    input           i_4x4_valid     ,
    output [5 :0]   o_switch_grant  ,
    output          o_grant_valid   ,

    input           i_config_end   
);

reg         ro_grant_valid  ;
reg  [5 :0] ro_switch_grant ;
reg  [5 :0] ro_switch_grant_reg ;
wire [7 :0] w_4x4_req       ;  

assign o_switch_grant = {ro_switch_grant[0],ro_switch_grant[1],ro_switch_grant[2],ro_switch_grant[3],ro_switch_grant[4],ro_switch_grant[5]} ;
assign o_grant_valid  = i_4x4_valid ? 1'b1 : 1'b0  ;
//上层模块输入：低端口请求在小端，即端口1目的为i_4x4_req[1:0]
assign w_4x4_req = {i_4x4_req[1:0],i_4x4_req[3:2],i_4x4_req[5:4],i_4x4_req[7:6]};

always @(*)begin
    ro_switch_grant = 'd0;
    if(i_4x4_valid)
        case (w_4x4_req)
            {2'd0,2'd1,2'd2,2'd3}   :   ro_switch_grant = {P_BAR,P_BAR,P_BAR,P_BAR,P_CROSS,P_CROSS};//bbbbcc
            {2'd0,2'd1,2'd3,2'd2}   :   ro_switch_grant = {P_BAR,P_BAR,P_BAR,P_BAR,P_CROSS,P_BAR};//bbbbcb
            {2'd0,2'd2,2'd1,2'd3}   :   ro_switch_grant = {P_BAR,P_CROSS,P_BAR,P_BAR,P_CROSS,P_CROSS};//bcbbcc
            {2'd0,2'd2,2'd3,2'd1}   :   ro_switch_grant = {P_BAR,P_CROSS,P_BAR,P_CROSS,P_CROSS,P_CROSS};//bcbccc
            {2'd0,2'd3,2'd1,2'd2}   :   ro_switch_grant = {P_BAR,P_CROSS,P_BAR,P_BAR,P_CROSS,P_BAR};//bcbbcb
            {2'd0,2'd3,2'd2,2'd1}   :   ro_switch_grant = {P_BAR,P_CROSS,P_BAR,P_CROSS,P_CROSS,P_BAR};//bcbccb

            {2'd1,2'd0,2'd2,2'd3}   :   ro_switch_grant = {P_CROSS,P_BAR,P_BAR,P_CROSS,P_CROSS,P_BAR};//cbbccb
            {2'd1,2'd0,2'd3,2'd2}   :   ro_switch_grant = {P_CROSS,P_BAR,P_BAR,P_BAR,P_CROSS,P_BAR};//cbbbcb
            {2'd1,2'd2,2'd0,2'd3}   :   ro_switch_grant = {P_CROSS,P_CROSS,P_BAR,P_BAR,P_CROSS,P_CROSS};//ccbbcc
            {2'd1,2'd2,2'd3,2'd0}   :   ro_switch_grant = {P_CROSS,P_CROSS,P_BAR,P_CROSS,P_CROSS,P_CROSS};//ccbccc
            {2'd1,2'd3,2'd0,2'd2}   :   ro_switch_grant = {P_CROSS,P_CROSS,P_BAR,P_BAR,P_CROSS,P_BAR};//ccbbcb
            {2'd1,2'd3,2'd2,2'd0}   :   ro_switch_grant = {P_CROSS,P_CROSS,P_BAR,P_CROSS,P_CROSS,P_BAR};//ccbccb

            {2'd2,2'd0,2'd1,2'd3}   :   ro_switch_grant = {P_CROSS,P_BAR,P_CROSS,P_CROSS,P_CROSS,P_BAR};//cbcccb
            {2'd2,2'd0,2'd3,2'd1}   :   ro_switch_grant = {P_CROSS,P_BAR,P_CROSS,P_BAR,P_CROSS,P_BAR};//cbcbcb
            {2'd2,2'd1,2'd0,2'd3}   :   ro_switch_grant = {P_CROSS,P_CROSS,P_CROSS,P_BAR,P_BAR,P_BAR};//cccbbb
            {2'd2,2'd1,2'd3,2'd0}   :   ro_switch_grant = {P_CROSS,P_CROSS,P_CROSS,P_CROSS,P_BAR,P_BAR};//ccccbb
            {2'd2,2'd3,2'd0,2'd1}   :   ro_switch_grant = {P_CROSS,P_CROSS,P_CROSS,P_BAR,P_CROSS,P_BAR};//cccbcb
            {2'd2,2'd3,2'd1,2'd0}   :   ro_switch_grant = {P_CROSS,P_CROSS,P_CROSS,P_CROSS,P_CROSS,P_BAR};//cccccb

            {2'd3,2'd0,2'd1,2'd2}   :   ro_switch_grant = {P_CROSS,P_BAR,P_CROSS,P_CROSS,P_CROSS,P_CROSS};//cbcccc
            {2'd3,2'd0,2'd2,2'd1}   :   ro_switch_grant = {P_CROSS,P_BAR,P_CROSS,P_BAR,P_CROSS,P_CROSS};//cbcbcc
            {2'd3,2'd1,2'd0,2'd2}   :   ro_switch_grant = {P_CROSS,P_CROSS,P_CROSS,P_BAR,P_BAR,P_CROSS};//cccbbc
            {2'd3,2'd1,2'd2,2'd0}   :   ro_switch_grant = {P_CROSS,P_CROSS,P_CROSS,P_CROSS,P_BAR,P_CROSS};//ccccbc
            {2'd3,2'd2,2'd0,2'd1}   :   ro_switch_grant = {P_CROSS,P_CROSS,P_CROSS,P_BAR,P_CROSS,P_CROSS};//cccbcc
            {2'd3,2'd2,2'd1,2'd0}   :   ro_switch_grant = {P_CROSS,P_CROSS,P_CROSS,P_CROSS,P_CROSS,P_CROSS};//cccccc
        endcase
    else
        ro_switch_grant = ro_switch_grant_reg;


end

always @(posedge i_clk)begin
    ro_switch_grant_reg <= ro_switch_grant;
end

always @(*)begin
    ro_grant_valid = 'd0;
    if(i_4x4_valid)
        ro_grant_valid = 'd1;
end
endmodule
