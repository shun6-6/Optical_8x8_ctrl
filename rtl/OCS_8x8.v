`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/07 15:10:35
// Design Name: 
// Module Name: OCS_8x8
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


module OCS_8x8#(
    parameter       P_BAR       =   1'b0,
    parameter       P_CROSS     =   1'b1   
)(
    input  [19:0]   i_grant ,
    input  [23:0]   i_data  ,
    output [23:0]   o_data  
);

wire [11:0] w_odata_4x4_0   ;
wire [11:0] w_odata_4x4_1   ;

wire [5 :0] w_odata_2x2_0   ;
wire [5 :0] w_odata_2x2_1   ;
wire [5 :0] w_odata_2x2_2   ;
wire [5 :0] w_odata_2x2_3   ;

OCS_2x2#(
    .P_BAR          (P_BAR                      ),
    .P_CROSS        (P_CROSS                    )
)OCS_2x2_in_u0(
    .i_grant        (i_grant[12]                ),
    .i_data         ({i_data[5:3],i_data[2:0]}  ),
    .o_data         (w_odata_2x2_0              ) 
);

OCS_2x2#(
    .P_BAR          (P_BAR                      ),
    .P_CROSS        (P_CROSS                    )
)OCS_2x2_in_u1(
    .i_grant        (i_grant[13]                ),
    .i_data         ({i_data[11:9],i_data[8:6]} ),
    .o_data         (w_odata_2x2_1              ) 
);

OCS_2x2#(
    .P_BAR          (P_BAR                      ),
    .P_CROSS        (P_CROSS                    )
)OCS_2x2_in_u2(
    .i_grant        (i_grant[14]                ),
    .i_data         ({i_data[17:15],i_data[14:12]}),
    .o_data         (w_odata_2x2_2              ) 
);

OCS_2x2#(
    .P_BAR          (P_BAR                      ),
    .P_CROSS        (P_CROSS                    )
)OCS_2x2_in_u3(
    .i_grant        (i_grant[15]                ),
    .i_data         ({i_data[23:21],i_data[20:18]}),
    .o_data         (w_odata_2x2_3              ) 
);

OCS_4x4#(
    .P_BAR              (1'b0           ),
    .P_CROSS            (1'b1           ) 
)OCS_4x4_u0(
    .i_grant            (i_grant[5:0]   ),
    .i_data             ({w_odata_2x2_3[2:0],w_odata_2x2_2[2:0],w_odata_2x2_1[2:0],w_odata_2x2_0[2:0]}),
    .o_data             (w_odata_4x4_0  )
);

OCS_4x4#(
    .P_BAR              (1'b0           ),
    .P_CROSS            (1'b1           ) 
)OCS_4x4_u1(
    .i_grant            (i_grant[11:6]  ),
    .i_data             ({w_odata_2x2_3[5:3],w_odata_2x2_2[5:3],w_odata_2x2_1[5:3],w_odata_2x2_0[5:3]}),
    .o_data             (w_odata_4x4_1  )
);

OCS_2x2#(
    .P_BAR          (P_BAR                      ),
    .P_CROSS        (P_CROSS                    )
)OCS_2x2_out_u0(
    .i_grant        (i_grant[16]                ),
    .i_data         ({w_odata_4x4_1[2:0],w_odata_4x4_0[2:0]}),
    .o_data         (o_data[5:0]                ) 
);

OCS_2x2#(
    .P_BAR          (P_BAR                      ),
    .P_CROSS        (P_CROSS                    )
)OCS_2x2_out_u1(
    .i_grant        (i_grant[17]                ),
    .i_data         ({w_odata_4x4_1[5:3],w_odata_4x4_0[5:3]}),
    .o_data         (o_data[11:6]               ) 
);

OCS_2x2#(
    .P_BAR          (P_BAR                      ),
    .P_CROSS        (P_CROSS                    )
)OCS_2x2_out_u2(
    .i_grant        (i_grant[18]                ),
    .i_data         ({w_odata_4x4_1[8:6],w_odata_4x4_0[8:6]}),
    .o_data         (o_data[17:12]              ) 
);

OCS_2x2#(
    .P_BAR          (P_BAR                      ),
    .P_CROSS        (P_CROSS                    )
)OCS_2x2_out_u3(
    .i_grant        (i_grant[19]                ),
    .i_data         ({w_odata_4x4_1[11:9],w_odata_4x4_0[11:9]}),
    .o_data         (o_data[23:18]              ) 
);

endmodule
