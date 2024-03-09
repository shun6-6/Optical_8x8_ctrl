`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/01 13:59:15
// Design Name: 
// Module Name: Optical_8x8_IN
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


module Optical_8x8_IN#(
    parameter       P_BAR       =   1'b0,
    parameter       P_CROSS     =   1'b1,
    parameter       P_DSTWIDTH  =   3   ,
    parameter       P_PORTNUM   =   8   ,
    parameter       P_SWITCHNUM =   4      
)(
    input                                   i_clk           ,
    input                                   i_rst           ,

    input  [P_DSTWIDTH*P_PORTNUM - 1:0]     i_8x8in_req     ,
    input                                   i_8x8in_valid   ,
    output [P_SWITCHNUM - 1:0]              o_switch_grant  ,
    output                                  o_grant_valid   ,

    output [P_DSTWIDTH*P_PORTNUM - 1:0]     o_8x8out_req    ,
    output                                  o_8x8out_valid  ,

    output [7 :0]                           o_4x4_req_1     ,
    output [7 :0]                           o_4x4_req_2     ,
    output                                  o_4x4_valid     ,

    input                                   i_config_end    
);
/***************function**************/

/***************parameter*************/         

/***************mechine***************/

/***************reg*******************/
//通过第一个4x4模块后的配置结果，并不完全正确
reg  [P_SWITCHNUM - 1:0]            ro_switch_grant     ;
reg                                 ro_grant_valid      ;
reg  [P_SWITCHNUM - 1:0]            ro_switch_grant_1d  ;
reg                                 ro_grant_valid_1d   ;
//通过第二个4x4模块后的配置结果，以此为最终结果
reg  [P_SWITCHNUM - 1:0]            ro_switch_grant_1   ;
reg                                 ro_grant_valid_1    ;
reg                                 ro_grant_valid_1_1d ;
reg                                 ro_grant_valid_1_2d ;
reg  [P_DSTWIDTH*P_PORTNUM - 1:0]   ro_8x8out_req       ;
reg                                 ro_8x8out_valid     ;
reg  [7 :0]                         ro_4x4_req_1        ;
reg  [7 :0]                         ro_4x4_req_2        ;
reg                                 ro_4x4_valid        ;

reg                                 ri_8x8in_valid      ;
reg  [P_DSTWIDTH*P_PORTNUM - 1:0]   ri_8x8in_req        ;   
//reg                                 r_config_end        ;
//记录每个输入端口的目的端口
//对于8x8输入级模块，记录他们需要的8x8输出端口
reg  [P_DSTWIDTH-1 :0]  dstOf_8x8port [P_PORTNUM - 1 :0];
//对于8x8输出级模块，记录他们需要的8x8输出端口
reg  [P_DSTWIDTH-1 :0]  dstOf_8x8endport [P_PORTNUM - 1 :0];
//需要经过一级4x4模块才可以输出，记录他们需要的4x4输出端口
reg  [P_DSTWIDTH-2 :0]  dstOf_4x4port [P_PORTNUM - 1 :0];   
//请求仲裁有效信号
reg                     r_req_4x4module_out_valid       ;
/***************wire******************/
//每个偶数端口向第一个4x4模块的每一个输出端口的请求：即端口0 2 4 6向第一个4x4模块的输出端口请求
wire [3 :0]             w_req_4x4module_out0            ;
wire [3 :0]             w_req_4x4module_out1            ;
wire [3 :0]             w_req_4x4module_out2            ;
wire [3 :0]             w_req_4x4module_out3            ;
//第一个4x4模块的每一个输出端口返回端口0 2 4 6的授权，得到授权的模块即可配置为bar模式，否则为cross
wire [3 :0]             w_grant_4x4module_out0          ;
wire [3 :0]             w_grant_4x4module_out1          ;
wire [3 :0]             w_grant_4x4module_out2          ;
wire [3 :0]             w_grant_4x4module_out3          ;
wire [3 :0]             w_grant_4x4module_out_valid     ;//指示授权有效信号
//讨论一：（失败）向第一个4x4模块请求结束之后，还需要将第一次配置完的结果与第二个4x4模块再进行一次请求，以彻底解决冲突
//讨论一：（失败）向第一个4x4模块请求结束之后，还会存在冲突，需要将优先级顺序调换，以保证第一次被配置的模块不会被二次修改，以彻底解决冲突
//讨论三：只要一次配置完后，第一个4x4模块存在任何一个端口没有数据输出时，即掉反优先级顺序继续仲裁
wire [3 :0]             w_req_4x4module_1_out0            ;
wire [3 :0]             w_req_4x4module_1_out1            ;
wire [3 :0]             w_req_4x4module_1_out2            ;
wire [3 :0]             w_req_4x4module_1_out3            ;

reg  [3 :0]             r_req_4x4module_1_out0            ;
reg  [3 :0]             r_req_4x4module_1_out1            ;
reg  [3 :0]             r_req_4x4module_1_out2            ;
reg  [3 :0]             r_req_4x4module_1_out3            ;

wire [3 :0]             w_grant_4x4module_1_out0          ;
wire [3 :0]             w_grant_4x4module_1_out1          ;
wire [3 :0]             w_grant_4x4module_1_out2          ;
wire [3 :0]             w_grant_4x4module_1_out3          ;
wire [3 :0]             w_grant_4x4module_1_out_valid     ;//指示授权有效信号
//调换优先级顺序
wire [3 :0]             w_req_4x4module_1_out0_opp        ;
wire [3 :0]             w_req_4x4module_1_out1_opp        ;
wire [3 :0]             w_req_4x4module_1_out2_opp        ;
wire [3 :0]             w_req_4x4module_1_out3_opp        ;
wire [3 :0]             w_grant_4x4module_1_out0_opp      ;
wire [3 :0]             w_grant_4x4module_1_out1_opp      ;
wire [3 :0]             w_grant_4x4module_1_out2_opp      ;
wire [3 :0]             w_grant_4x4module_1_out3_opp      ;
assign w_req_4x4module_1_out0_opp = {w_req_4x4module_1_out0[0],w_req_4x4module_1_out0[1],w_req_4x4module_1_out0[2],w_req_4x4module_1_out0[3]};
assign w_req_4x4module_1_out1_opp = {w_req_4x4module_1_out1[0],w_req_4x4module_1_out1[1],w_req_4x4module_1_out1[2],w_req_4x4module_1_out1[3]};
assign w_req_4x4module_1_out2_opp = {w_req_4x4module_1_out2[0],w_req_4x4module_1_out2[1],w_req_4x4module_1_out2[2],w_req_4x4module_1_out2[3]};
assign w_req_4x4module_1_out3_opp = {w_req_4x4module_1_out3[0],w_req_4x4module_1_out3[1],w_req_4x4module_1_out3[2],w_req_4x4module_1_out3[3]};

assign w_grant_4x4module_1_out0 = {w_grant_4x4module_1_out0_opp[0],w_grant_4x4module_1_out0_opp[1],w_grant_4x4module_1_out0_opp[2],w_grant_4x4module_1_out0_opp[3]};
assign w_grant_4x4module_1_out1 = {w_grant_4x4module_1_out1_opp[0],w_grant_4x4module_1_out1_opp[1],w_grant_4x4module_1_out1_opp[2],w_grant_4x4module_1_out1_opp[3]};
assign w_grant_4x4module_1_out2 = {w_grant_4x4module_1_out2_opp[0],w_grant_4x4module_1_out2_opp[1],w_grant_4x4module_1_out2_opp[2],w_grant_4x4module_1_out2_opp[3]};
assign w_grant_4x4module_1_out3 = {w_grant_4x4module_1_out3_opp[0],w_grant_4x4module_1_out3_opp[1],w_grant_4x4module_1_out3_opp[2],w_grant_4x4module_1_out3_opp[3]};
/***************component*************/
FIXED_Arbiter#(
    .P_CHANNEL_NUM      (4                          )
)FIXED_Arbiter_u0(
    .i_clk              (i_clk                      ),
    .i_rst              (i_rst                      ),
    .i_req              (w_req_4x4module_out0       ),
    .i_first_priority   ('d1                        ),
    .i_req_valid        (r_req_4x4module_out_valid  ),
    .o_grant            (w_grant_4x4module_out0     ),
    .o_grant_valid      (w_grant_4x4module_out_valid[0])  
);
FIXED_Arbiter#(
    .P_CHANNEL_NUM      (4                          )
)FIXED_Arbiter_u1(
    .i_clk              (i_clk                      ),
    .i_rst              (i_rst                      ),
    .i_req              (w_req_4x4module_out1       ),
    .i_first_priority   ('d1                       ),
    .i_req_valid        (r_req_4x4module_out_valid  ),
    .o_grant            (w_grant_4x4module_out1     ),
    .o_grant_valid      (w_grant_4x4module_out_valid[1]) 
);
FIXED_Arbiter#(
    .P_CHANNEL_NUM      (4                          )
)FIXED_Arbiter_u2(
    .i_clk              (i_clk                      ),
    .i_rst              (i_rst                      ),
    .i_req              (w_req_4x4module_out2       ),
    .i_first_priority   ('d1                        ),
    .i_req_valid        (r_req_4x4module_out_valid  ),
    .o_grant            (w_grant_4x4module_out2     ),
    .o_grant_valid      (w_grant_4x4module_out_valid[2]) 
);
FIXED_Arbiter#(
    .P_CHANNEL_NUM      (4                          )
)FIXED_Arbiter_u3(
    .i_clk              (i_clk                      ),
    .i_rst              (i_rst                      ),
    .i_req              (w_req_4x4module_out3       ),
    .i_first_priority   ('d1                        ),
    .i_req_valid        (r_req_4x4module_out_valid  ),
    .o_grant            (w_grant_4x4module_out3     ),
    .o_grant_valid      (w_grant_4x4module_out_valid[3])  
);

FIXED_Arbiter#(
    .P_CHANNEL_NUM      (4                          )
)FIXED_Arbiter_u4(
    .i_clk              (i_clk                      ),
    .i_rst              (i_rst                      ),
    .i_req              (w_req_4x4module_1_out0_opp     ),
    .i_first_priority   (4'b0001                        ),
    .i_req_valid        (ro_grant_valid  ),
    .o_grant            (w_grant_4x4module_1_out0_opp     ),
    .o_grant_valid      (w_grant_4x4module_1_out_valid[0])  
);

FIXED_Arbiter#(
    .P_CHANNEL_NUM      (4                          )
)FIXED_Arbiter_u5(
    .i_clk              (i_clk                      ),
    .i_rst              (i_rst                      ),
    .i_req              (w_req_4x4module_1_out1_opp     ),
    .i_first_priority   (4'b0001                          ),
    .i_req_valid        (ro_grant_valid  ),
    .o_grant            (w_grant_4x4module_1_out1_opp     ),
    .o_grant_valid      (w_grant_4x4module_1_out_valid[1])  
);

FIXED_Arbiter#(
    .P_CHANNEL_NUM      (4                          )
)FIXED_Arbiter_u6(
    .i_clk              (i_clk                      ),
    .i_rst              (i_rst                      ),
    .i_req              (w_req_4x4module_1_out2_opp     ),
    .i_first_priority   (4'b0001                          ),
    .i_req_valid        (ro_grant_valid  ),
    .o_grant            (w_grant_4x4module_1_out2_opp     ),
    .o_grant_valid      (w_grant_4x4module_1_out_valid[2])  
);

FIXED_Arbiter#(
    .P_CHANNEL_NUM      (4                          )
)FIXED_Arbiter_u7(
    .i_clk              (i_clk                      ),
    .i_rst              (i_rst                      ),
    .i_req              (w_req_4x4module_1_out3_opp     ),
    .i_first_priority   (4'b0001                         ),
    .i_req_valid        (ro_grant_valid  ),
    .o_grant            (w_grant_4x4module_1_out3_opp     ),
    .o_grant_valid      (w_grant_4x4module_1_out_valid[3])  
);

/***************assign****************/
assign o_switch_grant   = ro_switch_grant_1 ;
assign o_grant_valid    = ro_grant_valid_1  ;
assign o_8x8out_req     = ro_8x8out_req     ;
assign o_8x8out_valid   = ro_8x8out_valid   ;
assign o_4x4_req_1      = ro_4x4_req_1      ;
assign o_4x4_req_2      = ro_4x4_req_2      ;
assign o_4x4_valid      = ro_4x4_valid      ;


genvar k_1;
generate
    for(k_1 = 0 ; k_1 < 4 ; k_1 = k_1+1)begin
        assign w_req_4x4module_out0[k_1] = (dstOf_4x4port[2*k_1] == 0) ? 1'b1 : 1'b0;
        assign w_req_4x4module_out1[k_1] = (dstOf_4x4port[2*k_1] == 1) ? 1'b1 : 1'b0;
        assign w_req_4x4module_out2[k_1] = (dstOf_4x4port[2*k_1] == 2) ? 1'b1 : 1'b0;
        assign w_req_4x4module_out3[k_1] = (dstOf_4x4port[2*k_1] == 3) ? 1'b1 : 1'b0;
    end
endgenerate
//讨论一：
// genvar k_2;
// generate
//     for(k_2 = 0 ; k_2 < 4 ; k_2 = k_2+1)begin
//         assign w_req_4x4module_1_out0[k_2] = (ro_switch_grant[k_2] == P_BAR) ? 
//                                             (dstOf_4x4port[2*k_2 + 1] == 0) : (dstOf_4x4port[2*k_2] == 0);
//         assign w_req_4x4module_1_out1[k_2] = ro_switch_grant[k_2] == P_BAR ? 
//                                             (dstOf_4x4port[2*k_2 + 1] == 1) : (dstOf_4x4port[2*k_2] == 1);
//         assign w_req_4x4module_1_out2[k_2] = ro_switch_grant[k_2] == P_BAR ? 
//                                             (dstOf_4x4port[2*k_2 + 1] == 2) : (dstOf_4x4port[2*k_2] == 2);
//         assign w_req_4x4module_1_out3[k_2] = ro_switch_grant[k_2] == P_BAR ? 
//                                             (dstOf_4x4port[2*k_2 + 1] == 3) : (dstOf_4x4port[2*k_2] == 3);
//     end
// endgenerate
//讨论二：
genvar k_2;
generate
    for(k_2 = 0 ; k_2 < 4 ; k_2 = k_2+1)begin
        assign w_req_4x4module_1_out0[k_2] = (ro_switch_grant[k_2] == P_BAR) ? 
                                            (dstOf_4x4port[2*k_2] == 0) : (dstOf_4x4port[2*k_2 + 1] == 0);
        assign w_req_4x4module_1_out1[k_2] = ro_switch_grant[k_2] == P_BAR ? 
                                            (dstOf_4x4port[2*k_2] == 1) : (dstOf_4x4port[2*k_2 + 1] == 1);
        assign w_req_4x4module_1_out2[k_2] = ro_switch_grant[k_2] == P_BAR ? 
                                            (dstOf_4x4port[2*k_2] == 2) : (dstOf_4x4port[2*k_2 + 1] == 2);
        assign w_req_4x4module_1_out3[k_2] = ro_switch_grant[k_2] == P_BAR ? 
                                            (dstOf_4x4port[2*k_2] == 3) : (dstOf_4x4port[2*k_2 + 1] == 3);
    end
endgenerate

/***************always****************/
//8x8模块当中，对于每一个输入端口都对应一个要输出的端口，通过dstOf_8x8port记录
integer i;
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
        for(i = 0 ; i < P_PORTNUM ; i = i + 1)
            dstOf_8x8port[i] <= 'd0;
    end
    else if(i_8x8in_valid)begin
        for(i = 0 ; i < P_PORTNUM ; i = i + 1)
            dstOf_8x8port[i] <= i_8x8in_req[P_DSTWIDTH*i +: P_DSTWIDTH];
    end
    else if(i_config_end)begin
        for(i = 0 ; i < P_PORTNUM ; i = i + 1)
            dstOf_8x8port[i] <= 'd0;
    end
    else begin
        for(i = 0 ; i < P_PORTNUM ; i = i + 1)
            dstOf_8x8port[i] <= dstOf_8x8port[i];
    end
end
//8x8模块当中，对于每一个输入端口要到达输出端口都需要结果一级4x4模块，需要记录每一个输入通过4x4模块时会从哪个4x4模块相应的输出端口输出
integer j;
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
        for(j = 0 ; j < P_PORTNUM ; j = j + 1)
            dstOf_4x4port[j] <= 'd0;
    end
    else if(ri_8x8in_valid)begin
        for(j = 0 ; j < P_PORTNUM ; j = j + 1)
            dstOf_4x4port[j] <=  dstOf_8x8port[j] >> 1;
    end
    else if(i_config_end)begin
        for(j = 0 ; j < P_PORTNUM ; j = j + 1)
            dstOf_4x4port[j] <= 'd0;
    end
    else begin
        for(j = 0 ; j < P_PORTNUM ; j = j + 1)
            dstOf_4x4port[j] <= dstOf_4x4port[j];
    end
end
//请求仲裁有效信号
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_req_4x4module_out_valid <= 'd0;
    else if(ri_8x8in_valid)
        r_req_4x4module_out_valid <= 'd1;
    else
        r_req_4x4module_out_valid <= 'd0;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
        ri_8x8in_valid <= 'd0;
        ri_8x8in_req <= 'd0; 
        //r_config_end <= 'd0;       
    end
    else begin
        ri_8x8in_valid <= i_8x8in_valid; 
        ri_8x8in_req <= i_8x8in_req;  
        //r_config_end <= i_config_end;      
    end
end
//第一次得到仲裁结果后即对输入级的四个2x2模块的配置
genvar m;
generate
    for(m = 0 ; m < 4 ; m = m + 1)begin
        always @(posedge i_clk or posedge i_rst)begin
            if(i_rst)
                ro_switch_grant[m] <= 'd0;
            else if(w_req_4x4module_out0[m] && w_grant_4x4module_out0[m] && w_grant_4x4module_out_valid[0])
                ro_switch_grant[m] <= P_BAR;
            else if(w_req_4x4module_out1[m] && w_grant_4x4module_out1[m] && w_grant_4x4module_out_valid[1])
                ro_switch_grant[m] <= P_BAR;
            else if(w_req_4x4module_out2[m] && w_grant_4x4module_out2[m] && w_grant_4x4module_out_valid[2])
                ro_switch_grant[m] <= P_BAR;
            else if(w_req_4x4module_out3[m] && w_grant_4x4module_out3[m] && w_grant_4x4module_out_valid[3])
                ro_switch_grant[m] <= P_BAR;
            else
                ro_switch_grant[m] <= P_CROSS;
        end
    end
endgenerate

genvar m_1;
generate
    for(m_1 = 0 ; m_1 < 4 ; m_1 = m_1 + 1)begin
        always @(posedge i_clk or posedge i_rst)begin
            if(i_rst)
                ro_switch_grant_1[m_1] <= 'd0;
            else if(r_req_4x4module_1_out0[m_1] && !w_grant_4x4module_1_out0[m_1] && w_grant_4x4module_1_out_valid[0])
                ro_switch_grant_1[m_1] <= ~ro_switch_grant_1d[m_1];
            else if(r_req_4x4module_1_out1[m_1] && !w_grant_4x4module_1_out1[m_1] && w_grant_4x4module_1_out_valid[1])
                ro_switch_grant_1[m_1] <= ~ro_switch_grant_1d[m_1];
            else if(r_req_4x4module_1_out2[m_1] && !w_grant_4x4module_1_out2[m_1] && w_grant_4x4module_1_out_valid[2])
                ro_switch_grant_1[m_1] <= ~ro_switch_grant_1d[m_1];
            else if(r_req_4x4module_1_out3[m_1] && !w_grant_4x4module_1_out3[m_1] && w_grant_4x4module_1_out_valid[3])
                ro_switch_grant_1[m_1] <= ~ro_switch_grant_1d[m_1];
            else
                ro_switch_grant_1[m_1] <= ro_switch_grant_1d[m_1];
        end
    end
endgenerate

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
        r_req_4x4module_1_out0 <= 'd0;
        r_req_4x4module_1_out1 <= 'd0;
        r_req_4x4module_1_out2 <= 'd0;
        r_req_4x4module_1_out3 <= 'd0;
    end
    else begin
        r_req_4x4module_1_out0 <= w_req_4x4module_1_out0;
        r_req_4x4module_1_out1 <= w_req_4x4module_1_out1;
        r_req_4x4module_1_out2 <= w_req_4x4module_1_out2;
        r_req_4x4module_1_out3 <= w_req_4x4module_1_out3;
    end
end

//第一次输入级的四个2x2模块配置结果有效信号
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_grant_valid <= 'd0;
    else if(&w_grant_4x4module_out_valid)
        ro_grant_valid <= 'd1;
    else
        ro_grant_valid <= 'd0;
end
//第二次输入级的四个2x2模块配置结果有效信号
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_grant_valid_1 <= 'd0;
    else if(&w_grant_4x4module_1_out_valid)
        ro_grant_valid_1 <= 'd1;
    else
        ro_grant_valid_1 <= 'd0;
end


always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_4x4_valid <= 'd0;
    else if(ro_grant_valid_1 && !ro_grant_valid_1_1d)
        ro_4x4_valid <= 'd1;
    else
        ro_4x4_valid <= 'd0;
end
//通过输入级的模块配置结果，即可向2个4x4模块下发配置请求ro_4x4_req_1、ro_4x4_req_2
genvar n;
generate
    for(n = 0 ; n < 4 ; n = n + 1)begin
        always @(posedge i_clk or posedge i_rst)begin
            if(i_rst)
                ro_4x4_req_1[2*n +: 2] <= 'd0;
            else if(ro_switch_grant_1[n] == P_BAR && ro_grant_valid_1)
                ro_4x4_req_1[2*n +: 2] <= dstOf_4x4port[2*n];
            else
                ro_4x4_req_1[2*n +: 2] <= dstOf_4x4port[2*n + 1];
        end
    end

    for(n = 0 ; n < 4 ; n = n + 1)begin
        always @(posedge i_clk or posedge i_rst)begin
            if(i_rst)
                ro_4x4_req_2[2*n +: 2] <= 'd0;
            else if(ro_switch_grant_1[n] == P_BAR && ro_grant_valid_1)
                ro_4x4_req_2[2*n +: 2] <= dstOf_4x4port[2*n + 1];
            else
                ro_4x4_req_2[2*n +: 2] <= dstOf_4x4port[2*n];
        end
    end
//同时根据输入级模块的配置结果，可以得出输出级模块的输出请求，从而配置输出级模块的4个2x2模块
    for(n = 0 ; n < 4 ; n = n + 1)begin
        always @(posedge i_clk or posedge i_rst)begin
            if(i_rst)begin
                dstOf_8x8endport[2*n] <= 'd0;
                dstOf_8x8endport[2*n + 1] <= 'd0;
            end   
            else if(ro_switch_grant_1[n] == P_BAR && ro_grant_valid_1)begin
                dstOf_8x8endport[2 * dstOf_4x4port[2*n]] <= dstOf_8x8port[2*n];
                dstOf_8x8endport[2 * dstOf_4x4port[2*n+1] + 1] <= dstOf_8x8port[2*n + 1];
            end   
            else if(ro_switch_grant_1[n] == P_CROSS && ro_grant_valid_1)begin
                dstOf_8x8endport[2 * dstOf_4x4port[2*n+1]] <= dstOf_8x8port[2*n + 1];
                dstOf_8x8endport[2 * dstOf_4x4port[2*n] + 1] <= dstOf_8x8port[2*n];
            end  
            else begin
                dstOf_8x8endport[2*n] <= 'd0;
                dstOf_8x8endport[2*n + 1] <= 'd0;                
            end   
        end
    end

endgenerate

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
        ro_switch_grant_1d <= 'd0;
        ro_grant_valid_1d  <= 'd0;
    end
    else begin
        ro_switch_grant_1d <= ro_switch_grant;
        ro_grant_valid_1d  <= ro_grant_valid ;
    end
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
        ro_grant_valid_1_1d <= 'd0;
        ro_grant_valid_1_2d <= 'd0;
    end
    else begin
        ro_grant_valid_1_1d <= ro_grant_valid_1;
        ro_grant_valid_1_2d <= ro_grant_valid_1_1d;
    end
end

integer out_n;
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
        for(out_n = 0 ; out_n < P_PORTNUM ; out_n = out_n + 1)begin
            ro_8x8out_req[P_DSTWIDTH*out_n +: P_DSTWIDTH] <= 'd0;
        end
    end
    else if(ro_grant_valid_1_1d)begin
        for(out_n = 0 ; out_n < P_PORTNUM ; out_n = out_n + 1)begin
            ro_8x8out_req[P_DSTWIDTH*out_n +: P_DSTWIDTH] <= dstOf_8x8endport[out_n];
        end        
    end
    else begin
        for(out_n = 0 ; out_n < P_PORTNUM ; out_n = out_n + 1)begin
            ro_8x8out_req[P_DSTWIDTH*out_n +: P_DSTWIDTH] <= ro_8x8out_req[P_DSTWIDTH*out_n +: P_DSTWIDTH];
        end        
    end
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_8x8out_valid <= 'd0;
    else if(ro_grant_valid_1_1d && !ro_grant_valid_1_2d)
        ro_8x8out_valid <= 'd1;
    else
        ro_8x8out_valid <= 'd0;
end

endmodule
