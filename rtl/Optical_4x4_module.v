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


module Optical_4x4_module#(
    parameter       P_BAR   =   1'b0,
    parameter       P_CROSS =   1'b1   
)(
    input           i_clk           ,
    input           i_rst           ,

    input  [7 :0]   i_op_config     ,
    input           i_config_valid  ,
    output [3 :0]   o_switch_grant  ,
    output          o_grant_valid   
);

reg         ro_grant_valid  ;
reg  [3 :0] ro_switch_grant ;

assign o_switch_grant = ro_switch_grant ;
assign o_grant_valid  = ro_grant_valid  ;

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_switch_grant <= 'd0;
    else if(i_config_valid)
        case (i_op_config)
            {2'd1,2'd0,2'd2,2'd3}   :   ro_switch_grant <= {P_BAR,P_BAR,P_BAR,P_CROSS};
            {2'd1,2'd0,2'd3,2'd2}   :   ro_switch_grant <= {P_BAR,P_BAR,P_BAR,P_BAR};
            {2'd1,2'd2,2'd0,2'd3}   :   ro_switch_grant <= {P_CROSS,P_BAR,P_BAR,P_CROSS};
            {2'd1,2'd2,2'd3,2'd0}   :   ro_switch_grant <= {P_CROSS,P_BAR,P_CROSS,P_CROSS};
            {2'd1,2'd3,2'd0,2'd2}   :   ro_switch_grant <= {P_CROSS,P_BAR,P_BAR,P_BAR};
            {2'd1,2'd3,2'd2,2'd0}   :   ro_switch_grant <= {P_CROSS,P_BAR,P_CROSS,P_BAR};

            {2'd2,2'd0,2'd1,2'd3}   :   ro_switch_grant <= {P_BAR,P_CROSS,P_CROSS,P_BAR};
            {2'd2,2'd0,2'd3,2'd1}   :   ro_switch_grant <= {P_BAR,P_CROSS,P_BAR,P_BAR};
            {2'd2,2'd3,2'd0,2'd1}   :   ro_switch_grant <= {P_CROSS,P_CROSS,P_BAR,P_BAR};
            {2'd2,2'd3,2'd1,2'd0}   :   ro_switch_grant <= {P_CROSS,P_CROSS,P_CROSS,P_BAR};

            {2'd3,2'd0,2'd1,2'd2}   :   ro_switch_grant <= {P_BAR,P_CROSS,P_CROSS,P_CROSS};
            {2'd3,2'd0,2'd2,2'd1}   :   ro_switch_grant <= {P_BAR,P_CROSS,P_BAR,P_CROSS};
            {2'd3,2'd2,2'd0,2'd1}   :   ro_switch_grant <= {P_CROSS,P_CROSS,P_BAR,P_CROSS};
            {2'd3,2'd2,2'd1,2'd0}   :   ro_switch_grant <= {P_CROSS,P_CROSS,P_CROSS,P_CROSS};
        endcase
    else
        ro_switch_grant <= ro_switch_grant;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_grant_valid <= 'd0;
    else if(i_config_valid)
        ro_grant_valid <= 'd1;
    else
        ro_grant_valid <= 'd0;
end
endmodule
