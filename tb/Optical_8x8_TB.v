`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/06 20:27:40
// Design Name: 
// Module Name: Opticial_8x8_TB
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


module Optical_8x8_TB();

reg clk,rst;

always begin
    clk = 0;
    #10;
    clk = 1;
    #10;
end

initial begin
    rst = 1;
    #100;
    @(posedge clk) rst = 0;
end

wire [19:0] w_grant_8x8     ;
wire        w_grant_valid   ;

reg  [23:0] r_8x8_req       ;
reg         r_8x8_valid     ;

Optical_8x8_top#(
    .P_BAR              (1'b0),
    .P_CROSS            (1'b1),
    .P_DSTWIDTH         (3   ),
    .P_PORTNUM          (8   ),
    .P_SWITCHNUM        (4   )     
)Optical_8x8_top_u0(
    .i_clk              (clk            ),
    .i_rst              (rst            ),
    .i_8x8_req          (r_8x8_req      ),
    .i_8x8_valid        (r_8x8_valid    ),
    .o_grant_8x8        (w_grant_8x8    ),
    .o_grant_valid      (w_grant_valid  ) 
);

task optical_test();
begin
    r_8x8_req   <= 'd0;
    r_8x8_valid <= 'd0;    
    wait(!rst)
    repeat(10) @(posedge clk);
    r_8x8_req   <= {3'd7,3'd6,3'd5,3'd4,3'd3,3'd1,3'd2,3'd0};
    r_8x8_valid <= 'd1; 
    @(posedge clk);
    r_8x8_req   <= 'd0;
    r_8x8_valid <= 'd0;    
    @(posedge clk);   
end
endtask

initial begin
    r_8x8_req   = 'd0;
    r_8x8_valid = 'd0;
    wait(!rst)
    repeat(10) @(posedge clk);  
    optical_test();      
end

endmodule
