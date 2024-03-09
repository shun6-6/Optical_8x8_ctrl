`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/07 09:48:51
// Design Name: 
// Module Name: OCS_4x4
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


module OCS_4x4#(
    parameter       P_BAR       =   1'b0,
    parameter       P_CROSS     =   1'b1   
)(
    input  [5 :0]   i_grant ,
    input  [11:0]   i_data  ,
    output [11:0]   o_data  
);

wire [5 :0] w_odata_0;
wire [5 :0] w_odata_1;
wire [5 :0] w_odata_2;
wire [5 :0] w_odata_3;
wire [5 :0] w_odata_4;
wire [5 :0] w_odata_5;

assign o_data[2 :0] = w_odata_0[2 :0];
assign o_data[5 :3] = w_odata_2[2 :0];
assign o_data[8 :6] = w_odata_5[2 :0];
assign o_data[11:9] = w_odata_5[5 :3];

OCS_2x2#(
    .P_BAR          (P_BAR      ),
    .P_CROSS        (P_CROSS    )
)OCS_2x2_u0(
    .i_grant        (i_grant[0] ),
    .i_data         ({w_odata_1[2:0],i_data[2:0]}),
    .o_data         (w_odata_0  ) 
);

OCS_2x2#(
    .P_BAR          (P_BAR      ),
    .P_CROSS        (P_CROSS    )
)OCS_2x2_u1(
    .i_grant        (i_grant[1] ),
    .i_data         ({w_odata_3[2:0],i_data[5:3]}),
    .o_data         (w_odata_1  ) 
);

OCS_2x2#(
    .P_BAR          (P_BAR      ),
    .P_CROSS        (P_CROSS    )
)OCS_2x2_u2(
    .i_grant        (i_grant[2] ),
    .i_data         ({w_odata_4[2:0],w_odata_0[5:3]}),
    .o_data         (w_odata_2  ) 
);

OCS_2x2#(
    .P_BAR          (P_BAR      ),
    .P_CROSS        (P_CROSS    )
)OCS_2x2_u3(
    .i_grant        (i_grant[3] ),
    .i_data         ({i_data[11:9],i_data[8:6]}),
    .o_data         (w_odata_3  ) 
);

OCS_2x2#(
    .P_BAR          (P_BAR      ),
    .P_CROSS        (P_CROSS    )
)OCS_2x2_u4(
    .i_grant        (i_grant[4] ),
    .i_data         ({w_odata_3[5:3],w_odata_1[5:3]}),
    .o_data         (w_odata_4  ) 
);

OCS_2x2#(
    .P_BAR          (P_BAR      ),
    .P_CROSS        (P_CROSS    )
)OCS_2x2_u5(
    .i_grant        (i_grant[5] ),
    .i_data         ({w_odata_4[5:3],w_odata_2[5:3]}),
    .o_data         (w_odata_5  ) 
);

endmodule
