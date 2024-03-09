`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/07 10:19:34
// Design Name: 
// Module Name: OCS_4x4_TB
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


module OCS_4x4_TB();
    
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

reg  [7 :0]     r_4x4_req           ;
reg             r_4x4_valid         ;
wire [5 :0]     w_grant_4x4         ;
wire            w_4x4_grant_valid   ;
reg  [11:0]     r_data_in           ;
wire [11:0]     w_data_out          ;

reg r_4x4_grant_valid_1d;
reg [15:0]r_err_cnt;
reg [15:0]r_test_cnt;

Optical_4x4_module#(
    .P_BAR              (1'b0               ),
    .P_CROSS            (1'b1               )   
)Optical_4x4_module_u0(
    .i_clk              (clk                ),
    .i_rst              (rst                ),

    .i_4x4_req          (r_4x4_req          ),
    .i_4x4_valid        (r_4x4_valid        ),
    .o_switch_grant     (w_grant_4x4        ),
    .o_grant_valid      (w_4x4_grant_valid  ),
    .i_config_end       (0                  ) 
);

OCS_4x4#(
    .P_BAR              (1'b0               ),
    .P_CROSS            (1'b1               ) 
)OCS_4x4_u0(
    .i_grant            (w_grant_4x4        ),
    .i_data             (r_data_in          ),
    .o_data             (w_data_out         )
);

always @(posedge clk or posedge rst)begin
    if(rst)
        r_data_in <= 'd0;
    else if(w_4x4_grant_valid)
        r_data_in <= {1'b0,r_4x4_req[7:6],1'b0,r_4x4_req[5:4],1'b0,r_4x4_req[3:2],1'b0,r_4x4_req[1:0]};
    else
        r_data_in <= 'd0;
end

always @(posedge clk or posedge rst)begin
    if(rst)
        r_4x4_grant_valid_1d <= 'd0;
    else
        r_4x4_grant_valid_1d <= w_4x4_grant_valid;
end

always @(posedge clk or posedge rst)begin
    if(rst)
        r_err_cnt <= 'd0;
    else if(r_4x4_grant_valid_1d && w_data_out != 'h688)
        r_err_cnt <= r_err_cnt + 1;
    else
        r_err_cnt <= r_err_cnt;
end

always @(posedge clk or posedge rst)begin
    if(rst)
        r_test_cnt <= 'd0;
    else if(r_test_cnt == 24)
        r_test_cnt <= 'd0;
    else if(r_4x4_grant_valid_1d)
        r_test_cnt <= r_test_cnt + 1;
    else
        r_test_cnt <= r_test_cnt;
end
 

task OCS4x4_test();
begin
    r_4x4_req   <= 'd0;
    r_4x4_valid <= 'd0;
    wait(!rst);
    ///////////////////////////1
    repeat(20) @(posedge clk);
    r_4x4_req   <= {2'd3,2'd2,2'd1,2'd0};
    r_4x4_valid <= 'd1;
    repeat(1) @(posedge clk);
    r_4x4_req   <= r_4x4_req;
    r_4x4_valid <= 'd0;

    repeat(20) @(posedge clk);
    r_4x4_req   <= {2'd2,2'd3,2'd1,2'd0};
    r_4x4_valid <= 'd1;
    repeat(1) @(posedge clk);
    r_4x4_req   <= r_4x4_req;
    r_4x4_valid <= 'd0;

    repeat(20) @(posedge clk);
    r_4x4_req   <= {2'd3,2'd1,2'd2,2'd0};
    r_4x4_valid <= 'd1;
    repeat(1) @(posedge clk);
    r_4x4_req   <= r_4x4_req;
    r_4x4_valid <= 'd0;

    repeat(20) @(posedge clk);
    r_4x4_req   <= {2'd1,2'd3,2'd2,2'd0};
    r_4x4_valid <= 'd1;
    repeat(1) @(posedge clk);
    r_4x4_req   <= r_4x4_req;
    r_4x4_valid <= 'd0;

    repeat(20) @(posedge clk);
    r_4x4_req   <= {2'd2,2'd1,2'd3,2'd0};
    r_4x4_valid <= 'd1;
    repeat(1) @(posedge clk);
    r_4x4_req   <= r_4x4_req;
    r_4x4_valid <= 'd0;

    repeat(20) @(posedge clk);
    r_4x4_req   <= {2'd1,2'd2,2'd3,2'd0};
    r_4x4_valid <= 'd1;
    repeat(1) @(posedge clk);
    r_4x4_req   <= r_4x4_req;
    r_4x4_valid <= 'd0;

///////////////////////////2
    repeat(20) @(posedge clk);
    r_4x4_req   <= {2'd3,2'd2,2'd0,2'd1};
    r_4x4_valid <= 'd1;
    repeat(1) @(posedge clk);
    r_4x4_req   <= r_4x4_req;
    r_4x4_valid <= 'd0;

    repeat(20) @(posedge clk);
    r_4x4_req   <= {2'd2,2'd3,2'd0,2'd1};
    r_4x4_valid <= 'd1;
    repeat(1) @(posedge clk);
    r_4x4_req   <= r_4x4_req;
    r_4x4_valid <= 'd0;

    repeat(20) @(posedge clk);
    r_4x4_req   <= {2'd3,2'd0,2'd2,2'd1};
    r_4x4_valid <= 'd1;
    repeat(1) @(posedge clk);
    r_4x4_req   <= r_4x4_req;
    r_4x4_valid <= 'd0;

    repeat(20) @(posedge clk);
    r_4x4_req   <= {2'd0,2'd3,2'd2,2'd1};
    r_4x4_valid <= 'd1;
    repeat(1) @(posedge clk);
    r_4x4_req   <= r_4x4_req;
    r_4x4_valid <= 'd0;

    repeat(20) @(posedge clk);
    r_4x4_req   <= {2'd2,2'd0,2'd3,2'd1};
    r_4x4_valid <= 'd1;
    repeat(1) @(posedge clk);
    r_4x4_req   <= r_4x4_req;
    r_4x4_valid <= 'd0;

    repeat(20) @(posedge clk);
    r_4x4_req   <= {2'd0,2'd2,2'd3,2'd1};
    r_4x4_valid <= 'd1;
    repeat(1) @(posedge clk);
    r_4x4_req   <= r_4x4_req;
    r_4x4_valid <= 'd0;

    ///////////////////////////3
    repeat(20) @(posedge clk);
    r_4x4_req   <= {2'd3,2'd1,2'd0,2'd2};
    r_4x4_valid <= 'd1;
    repeat(1) @(posedge clk);
    r_4x4_req   <= r_4x4_req;
    r_4x4_valid <= 'd0;

    repeat(20) @(posedge clk);
    r_4x4_req   <= {2'd1,2'd3,2'd0,2'd2};
    r_4x4_valid <= 'd1;
    repeat(1) @(posedge clk);
    r_4x4_req   <= r_4x4_req;
    r_4x4_valid <= 'd0;

    repeat(20) @(posedge clk);
    r_4x4_req   <= {2'd3,2'd0,2'd1,2'd2};
    r_4x4_valid <= 'd1;
    repeat(1) @(posedge clk);
    r_4x4_req   <= r_4x4_req;
    r_4x4_valid <= 'd0;

    repeat(20) @(posedge clk);
    r_4x4_req   <= {2'd0,2'd3,2'd1,2'd2};
    r_4x4_valid <= 'd1;
    repeat(1) @(posedge clk);
    r_4x4_req   <= r_4x4_req;
    r_4x4_valid <= 'd0;

    repeat(20) @(posedge clk);
    r_4x4_req   <= {2'd1,2'd0,2'd3,2'd2};
    r_4x4_valid <= 'd1;
    repeat(1) @(posedge clk);
    r_4x4_req   <= r_4x4_req;
    r_4x4_valid <= 'd0;

    repeat(20) @(posedge clk);
    r_4x4_req   <= {2'd0,2'd1,2'd3,2'd2};
    r_4x4_valid <= 'd1;
    repeat(1) @(posedge clk);
    r_4x4_req   <= r_4x4_req;
    r_4x4_valid <= 'd0;

        ///////////////////////////4
    repeat(20) @(posedge clk);
    r_4x4_req   <= {2'd2,2'd1,2'd0,2'd3}; 
    r_4x4_valid <= 'd1;
    repeat(1) @(posedge clk);
    r_4x4_req   <= r_4x4_req;
    r_4x4_valid <= 'd0;

    repeat(20) @(posedge clk);
    r_4x4_req   <= {2'd1,2'd2,2'd0,2'd3};
    r_4x4_valid <= 'd1;
    repeat(1) @(posedge clk);
    r_4x4_req   <= r_4x4_req;
    r_4x4_valid <= 'd0;

    repeat(20) @(posedge clk);
    r_4x4_req   <= {2'd2,2'd0,2'd1,2'd3};
    r_4x4_valid <= 'd1;
    repeat(1) @(posedge clk);
    r_4x4_req   <= r_4x4_req;
    r_4x4_valid <= 'd0;

    repeat(20) @(posedge clk);
    r_4x4_req   <= {2'd0,2'd2,2'd1,2'd3};
    r_4x4_valid <= 'd1;
    repeat(1) @(posedge clk);
    r_4x4_req   <= r_4x4_req;
    r_4x4_valid <= 'd0;

    repeat(20) @(posedge clk);
    r_4x4_req   <= {2'd1,2'd0,2'd2,2'd3};
    r_4x4_valid <= 'd1;
    repeat(1) @(posedge clk);
    r_4x4_req   <= r_4x4_req;
    r_4x4_valid <= 'd0;

    repeat(20) @(posedge clk);
    r_4x4_req   <= {2'd0,2'd1,2'd2,2'd3};
    r_4x4_valid <= 'd1;
    repeat(1) @(posedge clk);
    r_4x4_req   <= r_4x4_req;
    r_4x4_valid <= 'd0;

end
endtask

initial begin
    r_4x4_req   = 'd0;
    r_4x4_valid = 'd0;
    wait(!rst);
    OCS4x4_test();
end

initial begin
    wait(r_test_cnt == 24);
    if(r_err_cnt == 0)
        $display("TEST PASSED");
    else
        $display("TEST ERROR %d times",r_err_cnt);
end

endmodule
