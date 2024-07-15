`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/07 15:35:43
// Design Name: 
// Module Name: OCS_8x8_TB
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


module OCS_8x8_TB();
    
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
reg  [19:0] r_grant_8x8     ;
wire        w_grant_valid   ;
reg         r_grant_valid   ;

reg  [23:0] r_8x8_req       ;
reg         r_8x8_valid     ;

reg  [23:0] r_data_in       ;
wire [23:0] w_data_out      ;

reg         r_grant_valid_1d;
reg  [15:0] r_err_cnt       ;
reg  [15:0] r_test_cnt      ;
 
reg  [2 :0] dstOfport [7:0] ;
// reg  [15:0] r_req_cnt       ;
// reg         r_req_valid     ;
 
reg         r_gen_valid     ;
reg  [15:0] r_gen_cnt       ;
reg         r_test_run      ;
reg         r_test_run_1d   ;
reg  [7 :0] r_rand_req_valid = 'd0;
//产生请求
always @(posedge clk or posedge rst)begin
    if(rst)
        r_test_run <= 'd0;
    else if(&r_rand_req_valid)
        r_test_run <= 'd0;
    else if(r_gen_valid)
        r_test_run <= 'd1;
    else
        r_test_run <= r_test_run;
end

always @(posedge clk or posedge rst)begin
    if(rst)
        r_test_run_1d <= 'd0;
    else
        r_test_run_1d <= r_test_run;
end

always @(posedge clk or posedge rst)begin
    if(rst)begin
        dstOfport[0]        <= 'd0;
        r_rand_req_valid[0] <= 'd0;
    end
    else if(!r_test_run && r_test_run_1d)begin
        dstOfport[0]        <= 'd0;
        r_rand_req_valid[0] <= 'd0;
    end
    else if(r_gen_valid)begin
        dstOfport[0]        <= {$random} % 8;
        r_rand_req_valid[0] <= 'd1;
    end
    else begin
        dstOfport[0]        <= dstOfport[0]       ;
        r_rand_req_valid[0] <= r_rand_req_valid[0];
    end  
end

always @(posedge clk or posedge rst)begin
    if(rst)begin
        dstOfport[1]        <= 'd0;
        r_rand_req_valid[1] <= 'd0;
    end
    else if(!r_test_run && r_test_run_1d)begin
        dstOfport[1]        <= 'd0;
        r_rand_req_valid[1] <= 'd0;
    end
    else if(r_rand_req_valid[0] && (dstOfport[1] != dstOfport[0]))begin
        dstOfport[1]        <= dstOfport[1];
        r_rand_req_valid[1] <= 'd1;
    end
    else begin
        dstOfport[1]        <= {$random} % 8;
        r_rand_req_valid[1] <= 'd0;
    end  
end

always @(posedge clk or posedge rst)begin
    if(rst)begin
        dstOfport[2]        <= 'd0;
        r_rand_req_valid[2] <= 'd0;
    end
    else if(!r_test_run && r_test_run_1d)begin
        dstOfport[2]        <= 'd0;
        r_rand_req_valid[2] <= 'd0;
    end
    else if(r_rand_req_valid[1] && (dstOfport[2] != dstOfport[0]) && (dstOfport[2] != dstOfport[1]))begin
        dstOfport[2]        <= dstOfport[2];
        r_rand_req_valid[2] <= 'd1;
    end
    else begin
        dstOfport[2]        <= {$random} % 8;
        r_rand_req_valid[2] <= 'd0;
    end  
end

always @(posedge clk or posedge rst)begin
    if(rst)begin
        dstOfport[3]        <= 'd0;
        r_rand_req_valid[3] <= 'd0;
    end
    else if(!r_test_run && r_test_run_1d)begin
        dstOfport[3]        <= 'd0;
        r_rand_req_valid[3] <= 'd0;
    end
    else if(r_rand_req_valid[2] && (dstOfport[3] != dstOfport[0]) && (dstOfport[3] != dstOfport[1]) && (dstOfport[3] != dstOfport[2]))begin
        dstOfport[3]        <= dstOfport[3];
        r_rand_req_valid[3] <= 'd1;
    end
    else begin
        dstOfport[3]        <= {$random} % 8;
        r_rand_req_valid[3] <= 'd0;
    end  
end

always @(posedge clk or posedge rst)begin
    if(rst)begin
        dstOfport[4]        <= 'd0;
        r_rand_req_valid[4] <= 'd0;
    end
    else if(!r_test_run && r_test_run_1d)begin
        dstOfport[4]        <= 'd0;
        r_rand_req_valid[4] <= 'd0;
    end
    else if(r_rand_req_valid[3] && (dstOfport[4] != dstOfport[0]) && (dstOfport[4] != dstOfport[1]) && (dstOfport[4] != dstOfport[2]) && (dstOfport[4] != dstOfport[3]))begin
        dstOfport[4]        <= dstOfport[4];
        r_rand_req_valid[4] <= 'd1;
    end
    else begin
        dstOfport[4]        <= {$random} % 8;
        r_rand_req_valid[4] <= 'd0;
    end  
end

always @(posedge clk or posedge rst)begin
    if(rst)begin
        dstOfport[5]        <= 'd0;
        r_rand_req_valid[5] <= 'd0;
    end
    else if(!r_test_run && r_test_run_1d)begin
        dstOfport[5]        <= 'd0;
        r_rand_req_valid[5] <= 'd0;
    end
    else if(r_rand_req_valid[4] && (dstOfport[5] != dstOfport[0]) && (dstOfport[5] != dstOfport[1]) && (dstOfport[5] != dstOfport[2]) && (dstOfport[5] != dstOfport[3]) && (dstOfport[5] != dstOfport[4]))begin
        dstOfport[5]        <= dstOfport[5];
        r_rand_req_valid[5] <= 'd1;
    end
    else begin
        dstOfport[5]        <= {$random} % 8;
        r_rand_req_valid[5] <= 'd0;
    end  
end

always @(posedge clk or posedge rst)begin
    if(rst)begin
        dstOfport[6]        <= 'd0;
        r_rand_req_valid[6] <= 'd0;
    end
    else if(!r_test_run && r_test_run_1d)begin
        dstOfport[6]        <= 'd0;
        r_rand_req_valid[6] <= 'd0;
    end
    else if(r_rand_req_valid[5] && (dstOfport[6] != dstOfport[0]) && (dstOfport[6] != dstOfport[1]) && (dstOfport[6] != dstOfport[2]) && (dstOfport[6] != dstOfport[3]) && (dstOfport[6] != dstOfport[4]) && (dstOfport[6] != dstOfport[5]))begin
        dstOfport[6]        <= dstOfport[6];
        r_rand_req_valid[6] <= 'd1;
    end
    else begin
        dstOfport[6]        <= {$random} % 8;
        r_rand_req_valid[6] <= 'd0;
    end  
end

always @(posedge clk or posedge rst)begin
    if(rst)begin
        dstOfport[7]        <= 'd0;
        r_rand_req_valid[7] <= 'd0;
    end
    else if(!r_test_run && r_test_run_1d)begin
        dstOfport[7]        <= 'd0;
        r_rand_req_valid[7] <= 'd0;
    end
    else if(r_rand_req_valid[6] && (dstOfport[7] != dstOfport[0]) && (dstOfport[7] != dstOfport[1]) && (dstOfport[7] != dstOfport[2]) && (dstOfport[7] != dstOfport[3]) && (dstOfport[7] != dstOfport[4]) && (dstOfport[7] != dstOfport[5]) && (dstOfport[7] != dstOfport[6]))begin
        dstOfport[7]        <= dstOfport[7];
        r_rand_req_valid[7] <= 'd1;
    end
    else begin
        dstOfport[7]        <= {$random} % 8;
        r_rand_req_valid[7] <= 'd0;
    end  
end

integer i;

always @(posedge clk or posedge rst)begin
    if(rst)
        r_8x8_req <= 'd0;
    else if(&r_rand_req_valid)begin
        for(i = 0 ; i < 8 ; i = i + 1)
        r_8x8_req[3*i +: 3] <= dstOfport[i];
    end
    else
        r_8x8_req <= r_8x8_req;
end

always @(posedge clk or posedge rst)begin
    if(rst)
        r_8x8_valid <= 'd0;
    else if(r_8x8_valid)
        r_8x8_valid <= 'd0;
    else if(&r_rand_req_valid)
        r_8x8_valid <= 'd1;
    else
        r_8x8_valid <= 'd0;
    end
//接口赋值
always @(posedge clk or posedge rst)begin
    if(rst)
        r_data_in <= 'd0;
    else if(w_grant_valid)
        r_data_in <= r_8x8_req;
    else
        r_data_in <= r_data_in;
end

always @(posedge clk or posedge rst)begin
    if(rst)
        r_grant_8x8 <= 'd0;
    else if(w_grant_valid)
        r_grant_8x8 <= w_grant_8x8;
    else
        r_grant_8x8 <= r_grant_8x8;
end
//错误检测
always @(posedge clk or posedge rst)begin
    if(rst)
        r_grant_valid_1d <= 'd0;
    else
        r_grant_valid_1d <= w_grant_valid;
end

always @(posedge clk or posedge rst)begin
    if(rst)
        r_err_cnt <= 'd0;
    else if(r_grant_valid_1d && w_data_out != 'hfac688)
        r_err_cnt <= r_err_cnt + 1;
    else
        r_err_cnt <= r_err_cnt;
end

always @(posedge clk or posedge rst)begin
    if(rst)
        r_test_cnt <= 'd0;
    else if(&r_test_cnt)
        r_test_cnt <= 'd0;
    else if(r_grant_valid_1d)
        r_test_cnt <= r_test_cnt + 1;
    else
        r_test_cnt <= r_test_cnt;
end



OCS_8x8#(
    .P_BAR      (1'b0),
    .P_CROSS    (1'b1)   
)OCS_8x8_u0(
    .i_grant    (r_grant_8x8    ),
    .i_data     (r_data_in      ),
    .o_data     (w_data_out     ) 
);

Optical_8x8ctrl_top#(
    .P_BAR              (1'b0),
    .P_CROSS            (1'b1),
    .P_DSTWIDTH         (3   ),
    .P_PORTNUM          (8   ),
    .P_SWITCHNUM        (4   )     
)Optical_8x8ctrl_top_u0(
    .i_clk              (clk            ),
    .i_rst              (rst            ),
    .i_8x8_req          (r_8x8_req      ),
    .i_8x8_valid        (r_8x8_valid    ),
    .o_grant_8x8        (w_grant_8x8    ),
    .o_grant_valid      (w_grant_valid  ) 
);

// task Gen_8x8_test_first();
// begin
//     r_gen_valid <= 'd0;  
//     wait(!rst);
//     @(posedge clk);
//     if(!r_test_run)begin
//         repeat(20)@(posedge clk);
//         r_gen_valid <= 'd1; 
//     end
//     @(posedge clk);
//     r_gen_valid <= 'd0; 
//     @(posedge clk);
// end
// endtask

// task Gen_8x8_test();
// begin 
//     wait(!rst);
//     @(posedge clk);
//     if(r_gen_cnt == 0)begin
//         r_gen_cnt <= 'd1;
//         if(!r_test_run)begin
//             r_gen_valid <= 'd1; 
//         end
//         else
//             r_gen_valid <= 'd0; 
//     end
//     else begin
//         if((!r_test_run) && w_grant_valid)begin
//             r_gen_valid <= 'd1; 
//         end
//         else 
//             r_gen_valid <= 'd0; 
//     end
//     @(posedge clk);
//     r_gen_valid <= 'd0; 
// end
// endtask
always @(posedge clk or posedge rst)begin
    if(rst)
        r_grant_valid <= 'd0; 
    else if(r_gen_valid)
        r_grant_valid <= 'd0; 
    else if(w_grant_valid)
        r_grant_valid <= 'd1; 
    else
        r_grant_valid <= r_grant_valid; 
end

always @(posedge clk or posedge rst)begin
    if(rst)
        r_gen_valid <= 'd0; 
    else if(r_gen_cnt == 0 && !r_test_run)
        r_gen_valid <= 'd1; 
    else if(r_gen_cnt != 0 && !r_test_run && r_grant_valid)
        r_gen_valid <= 'd1; 
    else
        r_gen_valid <= 'd0; 
end

always @(posedge clk or posedge rst)begin
    if(rst)
        r_gen_cnt <= 'd0; 
    else if(r_gen_cnt == 1)
        r_gen_cnt <= r_gen_cnt; 
    else if(r_gen_valid)
        r_gen_cnt <= r_gen_cnt +'d1; 
    else
        r_gen_cnt <= r_gen_cnt; 
end

initial begin
    r_gen_cnt = 'd0;
    r_8x8_req   = 'd0;
    r_8x8_valid = 'd0;
    r_8x8_req   = 'd0;
    r_8x8_valid = 'd0;
    r_gen_valid = 0;
    // wait(!rst);
    // forever begin
    //     wait(w_grant_valid);
    //     Gen_8x8_test();
    // end
end

endmodule
