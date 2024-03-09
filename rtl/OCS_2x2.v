`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/07 09:51:50
// Design Name: 
// Module Name: OCS_2x2
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


module OCS_2x2#(
    parameter       P_BAR       =   1'b0,
    parameter       P_CROSS     =   1'b1   
)(
    input  [0 :0]   i_grant ,
    input  [5 :0]   i_data  ,
    output [5 :0]   o_data  
);

assign o_data[2:0] = i_grant == P_BAR ? i_data[2:0] : i_data[5:3];
assign o_data[5:3] = i_grant == P_BAR ? i_data[5:3] : i_data[2:0];

endmodule
