`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/06 19:41:26
// Design Name: 
// Module Name: Opticial_8x8_top
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


module Optical_8x8ctrl_top#(
    parameter       P_BAR       =   1'b0,
    parameter       P_CROSS     =   1'b1,
    parameter       P_DSTWIDTH  =   3   ,
    parameter       P_PORTNUM   =   8   ,
    parameter       P_SWITCHNUM =   4      
)(
    input                                   i_clk           ,
    input                                   i_rst           ,
    input  [P_DSTWIDTH*P_PORTNUM - 1:0]     i_8x8_req       ,
    input                                   i_8x8_valid     ,
    output [19:0]                           o_grant_8x8     ,
    output                                  o_grant_valid   
);
/***************function**************/

/***************parameter*************/

/***************port******************/             

/***************mechine***************/

/***************reg*******************/
wire                                r_config_end        ;

reg                                 r_8x8in_grant_valid ;
reg                                 r_4x4_grant_valid_1 ;
reg                                 r_4x4_grant_valid_2 ;
reg                                 r_8x8out_grant_valid;
reg  [3 :0]                         r_grant_8x8in       ;
reg  [3 :0]                         r_grant_8x8out      ;
reg  [5 :0]                         r_grant_4x4_1       ;
reg  [5 :0]                         r_grant_4x4_2       ;
/***************wire******************/
wire [3 :0]                         w_grant_8x8in       ;
wire [3 :0]                         w_grant_8x8out      ;
wire [5 :0]                         w_grant_4x4_1       ;
wire [5 :0]                         w_grant_4x4_2       ;

wire                                w_8x8in_grant_valid ;
wire                                w_4x4_grant_valid_1 ;
wire                                w_4x4_grant_valid_2 ;
wire                                w_8x8out_grant_valid;

wire [P_DSTWIDTH*P_PORTNUM - 1:0]   w_8x8out_req        ;
wire                                w_8x8out_valid      ;
wire [7 :0]                         w_4x4_req_1         ;
wire [7 :0]                         w_4x4_req_2         ;
wire                                w_4x4_valid         ;
/***************component*************/
Optical_8x8ctrl_IN#(
    .P_BAR              (P_BAR              ),
    .P_CROSS            (P_CROSS            ),
    .P_DSTWIDTH         (P_DSTWIDTH         ),
    .P_PORTNUM          (P_PORTNUM          ),
    .P_SWITCHNUM        (P_SWITCHNUM        )   
)Optical_8x8ctrl_IN_u0(
    .i_clk              (i_clk              ),
    .i_rst              (i_rst              ),

    .i_8x8in_req        (i_8x8_req          ),
    .i_8x8in_valid      (i_8x8_valid        ),
    .o_switch_grant     (w_grant_8x8in      ),
    .o_grant_valid      (w_8x8in_grant_valid),

    .o_8x8out_req       (w_8x8out_req       ),
    .o_8x8out_valid     (w_8x8out_valid     ),

    .o_4x4_req_1        (w_4x4_req_1        ),
    .o_4x4_req_2        (w_4x4_req_2        ),
    .o_4x4_valid        (w_4x4_valid        ),

    .i_config_end       (r_config_end       ) 
);

Optical_4x4ctrl_module#(
    .P_BAR              (P_BAR              ),
    .P_CROSS            (P_CROSS            )   
)Optical_4x4ctrl_module_u0(
    .i_clk              (i_clk              ),
    .i_rst              (i_rst              ),

    .i_4x4_req          (w_4x4_req_1        ),
    .i_4x4_valid        (w_4x4_valid        ),
    .o_switch_grant     (w_grant_4x4_1      ),
    .o_grant_valid      (w_4x4_grant_valid_1),
    .i_config_end       (r_config_end       ) 
);

Optical_4x4ctrl_module#(
    .P_BAR              (P_BAR              ),
    .P_CROSS            (P_CROSS            )   
)Optical_4x4ctrl_module_u1(
    .i_clk              (i_clk              ),
    .i_rst              (i_rst              ),

    .i_4x4_req          (w_4x4_req_2        ),
    .i_4x4_valid        (w_4x4_valid        ),
    .o_switch_grant     (w_grant_4x4_2      ),
    .o_grant_valid      (w_4x4_grant_valid_2),
    .i_config_end       (r_config_end       ) 
);

Optical_8x8ctrl_OUT#(
    .P_BAR              (P_BAR              ),
    .P_CROSS            (P_CROSS            ),
    .P_DSTWIDTH         (P_DSTWIDTH         ),
    .P_PORTNUM          (P_PORTNUM          ),
    .P_SWITCHNUM        (P_SWITCHNUM        )     
)Optical_8x8ctrl_OUT_u0(
    .i_clk              (i_clk              ),
    .i_rst              (i_rst              ),

    .i_8x8out_req       (w_8x8out_req       ),
    .i_8x8out_valid     (w_8x8out_valid     ),
    .o_switch_grant     (w_grant_8x8out     ),
    .o_grant_valid      (w_8x8out_grant_valid),

    .i_config_end       (r_config_end       ) 
);
/***************assign****************/
assign r_config_end = o_grant_valid;
assign o_grant_8x8 = {r_grant_8x8out,r_grant_8x8in,r_grant_4x4_2,r_grant_4x4_1};
assign o_grant_valid = r_8x8in_grant_valid & r_4x4_grant_valid_1 & r_4x4_grant_valid_2 & r_8x8out_grant_valid;
/***************always****************/

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
        r_8x8in_grant_valid <= 'd0;
        r_grant_8x8in       <= 'd0;
    end
    else if(r_config_end)begin
        r_8x8in_grant_valid <= 'd0;
        r_grant_8x8in       <= 'd0;  
    end
    else if(w_8x8in_grant_valid)begin
        r_8x8in_grant_valid <= w_8x8in_grant_valid;
        r_grant_8x8in       <= w_grant_8x8in;      
    end
    else begin
        r_8x8in_grant_valid <= r_8x8in_grant_valid;
        r_grant_8x8in       <= r_grant_8x8in      ;        
    end
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
        r_4x4_grant_valid_1 <= 'd0;
        r_grant_4x4_1       <= 'd0;
    end
    else if(r_config_end)begin
        r_4x4_grant_valid_1 <= 'd0;
        r_grant_4x4_1       <= 'd0;  
    end
    else if(w_4x4_grant_valid_1)begin
        r_4x4_grant_valid_1 <= w_4x4_grant_valid_1;
        r_grant_4x4_1       <= w_grant_4x4_1      ;
    end
    else begin
        r_4x4_grant_valid_1 <= r_4x4_grant_valid_1;
        r_grant_4x4_1       <= r_grant_4x4_1      ;        
    end
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
        r_4x4_grant_valid_2 <= 'd0;
        r_grant_4x4_2       <= 'd0;
    end
    else if(r_config_end)begin
        r_4x4_grant_valid_2 <= 'd0;
        r_grant_4x4_2       <= 'd0;  
    end
    else if(w_4x4_grant_valid_2)begin
        r_4x4_grant_valid_2 <= w_4x4_grant_valid_2;
        r_grant_4x4_2       <= w_grant_4x4_2;      
    end
    else begin
        r_4x4_grant_valid_2 <= r_4x4_grant_valid_2;
        r_grant_4x4_2       <= r_grant_4x4_2      ;        
    end
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
        r_8x8out_grant_valid <= 'd0;
        r_grant_8x8out       <= 'd0;
    end
    else if(r_config_end)begin
        r_8x8out_grant_valid <= 'd0;
        r_grant_8x8out       <= 'd0;  
    end
    else if(w_8x8out_grant_valid)begin
        r_8x8out_grant_valid <= w_8x8out_grant_valid;
        r_grant_8x8out       <= w_grant_8x8out      ;
    end
    else begin
        r_8x8out_grant_valid <= r_8x8out_grant_valid;
        r_grant_8x8out       <= r_grant_8x8out      ;        
    end
end

endmodule
