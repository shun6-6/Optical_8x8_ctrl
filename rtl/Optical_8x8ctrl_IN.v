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


module Optical_8x8ctrl_IN#(
    parameter       P_BAR       =   1'b0,
    parameter       P_CROSS     =   1'b1,
    parameter       P_DSTWIDTH  =   3   ,
    parameter       P_PORTNUM   =   8   ,
    parameter       P_SWITCHNUM =   4   ,
    parameter       P_INTER     =   4   
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
reg  [P_SWITCHNUM - 1:0]            r_switch_grant      ;
reg                                 r_grant_valid       ;
reg  [P_SWITCHNUM - 1:0]            ro_switch_grant [P_INTER - 1 : 0]   ;
reg  [P_SWITCHNUM - 1:0]            ro_switch_grant_reg  [P_INTER - 1 : 0];
reg                                 ro_grant_valid  [P_INTER - 1 : 0]    ;

reg                                 ro_grant_valid_1d   ;

//通过第二个4x4模块后的配置结果，以此为最终结果

reg                                 r_config_continue [P_INTER - 1 : 0]  ;
reg                                 r_config_continue_reg [P_INTER - 1 : 0]  ;

reg  [P_DSTWIDTH*P_PORTNUM - 1:0]   ro_8x8out_req       ;
reg  [P_DSTWIDTH*P_PORTNUM - 1:0]   ro_8x8out_req_reg = 0  ;
reg                                 ro_8x8out_valid     ;
reg  [7 :0]                         ro_4x4_req_1     [P_INTER - 1 : 0]   ;
reg  [7 :0]                         ro_4x4_req_2     [P_INTER - 1 : 0]   ;
reg  [7 :0]                         ro_4x4_req_1_reg [P_INTER - 1 : 0]   ;
reg  [7 :0]                         ro_4x4_req_2_reg [P_INTER - 1 : 0]   ;
reg                                 ro_4x4_valid        ;
reg  [7 :0]                         ro_4x4_req_1_1d     ;
reg  [7 :0]                         ro_4x4_req_2_1d     ;
reg                                 ro_4x4_valid_1d = 0    ;
reg                                 ri_8x8in_valid      ;
reg                                 ri_8x8in_valid_1d   ;
reg  [P_DSTWIDTH*P_PORTNUM - 1:0]   ri_8x8in_req        ;   
//reg                                 r_config_end        ;
//记录每个输入端口的目的端口
//对于8x8输入级模块，记录他们需要的8x8输出端口
reg  [P_DSTWIDTH-1 :0]  dstOf_8x8port [P_PORTNUM - 1 :0];
reg  [P_DSTWIDTH-1 :0]  dstOf_8x8port_reg [P_PORTNUM - 1 :0];
//对于8x8输出级模块，记录他们需要的8x8输出端口
reg  [P_DSTWIDTH-1 :0]  dstOf_8x8endport [P_PORTNUM - 1 :0];
reg  [P_DSTWIDTH-1 :0]  dstOf_8x8endport_reg [P_PORTNUM - 1 :0];
//需要经过一级4x4模块才可以输出，记录他们需要的4x4输出端口
reg  [P_DSTWIDTH-2 :0]  dstOf_4x4port [P_PORTNUM - 1 :0];   
reg  [P_DSTWIDTH-2 :0]  dstOf_4x4port_reg [P_PORTNUM - 1 :0];
/***************wire******************/
//讨论一：（失败）向第一个4x4模块请求结束之后，还需要将第一次配置完的结果与第二个4x4模块再进行一次请求，以彻底解决冲突
//讨论一：（失败）向第一个4x4模块请求结束之后，还会存在冲突，需要将优先级顺序调换，以保证第一次被配置的模块不会被二次修改，以彻底解决冲突
//讨论三：（失败）只要一次配置完后，第一个4x4模块存在任何一个端口没有数据输出时，即掉反优先级顺序继续仲裁
//讨论四：（成功）固定优先级控制器，每次仲裁结果当中，仲裁失败从而改变配置的模块在下一次仲裁当中具有最高优先级
//请求仲裁有效信号
reg                     r_req_4x4module_out_valid [P_INTER - 1 : 0]      ;
reg  [3 :0]             r_first_priority  [P_INTER - 1 : 0]               ;
reg  [3 :0]             r_first_priority_reg  [P_INTER - 1 : 0]               ;
reg  [3 :0]             r_req_4x4module_out0  [P_INTER - 1 : 0]          ;
reg  [3 :0]             r_req_4x4module_out1  [P_INTER - 1 : 0]          ;
reg  [3 :0]             r_req_4x4module_out2  [P_INTER - 1 : 0]          ;
reg  [3 :0]             r_req_4x4module_out3  [P_INTER - 1 : 0]          ;
reg  [3 :0]             r_req_4x4module_out0_reg [P_INTER - 1 : 0]       ;
reg  [3 :0]             r_req_4x4module_out1_reg [P_INTER - 1 : 0]       ;
reg  [3 :0]             r_req_4x4module_out2_reg [P_INTER - 1 : 0]       ;
reg  [3 :0]             r_req_4x4module_out3_reg [P_INTER - 1 : 0]       ;
reg  [2 :0]             r_config_cnt [P_INTER - 1 : 0];
reg  [2 :0]             r_config_cnt_reg [P_INTER - 1 : 0];
//第一个4x4模块的每一个输出端口返回端口0 2 4 6的授权，得到授权的模块即可配置为bar模式，否则为cross
wire [3 :0]             w_grant_4x4module_out0       [P_INTER - 1 : 0]  ;
wire [3 :0]             w_grant_4x4module_out1       [P_INTER - 1 : 0]  ;
wire [3 :0]             w_grant_4x4module_out2       [P_INTER - 1 : 0]  ;
wire [3 :0]             w_grant_4x4module_out3       [P_INTER - 1 : 0]  ;
wire [3 :0]             w_grant_4x4module_out_valid  [P_INTER - 1 : 0]  ;//指示授权有效信号
/***************component*************/

/***************assign****************/
assign o_switch_grant   = r_switch_grant    ;
assign o_grant_valid    = r_grant_valid     ;
assign o_8x8out_req     = ro_8x8out_req     ;
assign o_8x8out_valid   = ro_4x4_valid_1d   ;
assign o_4x4_req_1      = ro_4x4_req_1_1d   ;
assign o_4x4_req_2      = ro_4x4_req_2_1d   ;
assign o_4x4_valid      = ro_4x4_valid_1d   ;

/***************always****************/
//8x8模块当中，对于每一个输入端口都对应一个要输出的端口，通过dstOf_8x8port记录
integer i;
always @(*)begin
    if(i_rst)begin
        for(i = 0 ; i < P_PORTNUM ; i = i + 1)
            dstOf_8x8port[i] = 'd0;
    end
    else if(i_8x8in_valid)begin
        for(i = 0 ; i < P_PORTNUM ; i = i + 1)
            dstOf_8x8port[i] = i_8x8in_req[P_DSTWIDTH*i +: P_DSTWIDTH];
    end
    else if(i_config_end)begin
        for(i = 0 ; i < P_PORTNUM ; i = i + 1)
            dstOf_8x8port[i] = 'd0;
    end
    else begin
        for(i = 0 ; i < P_PORTNUM ; i = i + 1)
            dstOf_8x8port[i] = dstOf_8x8port_reg[i];
    end
end
always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)begin
        for(i = 0 ; i < P_PORTNUM ; i = i + 1)
            dstOf_8x8port_reg[i] <= 'd0;
    end
    else begin
        for(i = 0 ; i < P_PORTNUM ; i = i + 1)
            dstOf_8x8port_reg[i] <= dstOf_8x8port[i];
    end
end
//8x8模块当中，对于每一个输入端口要到达输出端口都需要结果一级4x4模块，需要记录每一个输入通过4x4模块时会从哪个4x4模块相应的输出端口输出
integer j;
always @(*)begin
    if(i_rst)begin
        for(j = 0 ; j < P_PORTNUM ; j = j + 1)
            dstOf_4x4port[j] = 'd0;
    end
    else if(i_8x8in_valid)begin
        for(j = 0 ; j < P_PORTNUM ; j = j + 1)
            dstOf_4x4port[j] = dstOf_8x8port[j] >> 1;
    end
    else if(i_config_end)begin
        for(j = 0 ; j < P_PORTNUM ; j = j + 1)
            dstOf_4x4port[j] = 'd0;
    end
    else begin
        for(j = 0 ; j < P_PORTNUM ; j = j + 1)
            dstOf_4x4port[j] = dstOf_4x4port_reg[j];
    end
end
always @(posedge i_clk or posedge i_rst) begin
    if(i_rst)begin
        for(j = 0 ; j < P_PORTNUM ; j = j + 1)
            dstOf_4x4port_reg[j] <= 'd0;
    end
    else begin
        for(j = 0 ; j < P_PORTNUM ; j = j + 1)
            dstOf_4x4port_reg[j] <= dstOf_4x4port[j];
    end
end

/////////////////////////////////////////////////////////////////
//通过generate实现多次仲裁，一个时钟周期得出最终的仲裁结果，为了避免loop，所有相关信号都使用一维数组声明三次，进行后续迭代
/////////////////////////////////////////////////////////////////
genvar m;
genvar gen_i;
generate
    for(gen_i = 0 ; gen_i < P_INTER ; gen_i = gen_i + 1)begin
        always @(*)begin
            if(i_rst)
                r_first_priority[gen_i] = 4'b0001;
            else if(r_grant_valid)
                r_first_priority[gen_i] = 4'b0001;
            else if(i_8x8in_valid && gen_i == 0)
                r_first_priority[gen_i] = 4'b0001;
            else if(r_config_continue[gen_i - 1] && (ro_switch_grant[gen_i][0] != ro_switch_grant[gen_i - 1][0]) && gen_i > 0)
                r_first_priority[gen_i] = 4'b0001;
            else if(r_config_continue[gen_i - 1] && (ro_switch_grant[gen_i][1] != ro_switch_grant[gen_i - 1][1]) && gen_i > 0)
                r_first_priority[gen_i] = 4'b0010;
            else if(r_config_continue[gen_i - 1] && (ro_switch_grant[gen_i][2] != ro_switch_grant[gen_i - 1][2]) && gen_i > 0)
                r_first_priority[gen_i] = 4'b0100;
            else if(r_config_continue[gen_i - 1] && (ro_switch_grant[gen_i][3] != ro_switch_grant[gen_i - 1][3]) && gen_i > 0)
                r_first_priority[gen_i] = 4'b1000;
            else
                r_first_priority[gen_i] = 4'b0001;
        end
        always @(posedge i_clk or posedge i_rst)begin
            if(i_rst)
                r_first_priority_reg[gen_i] <= 4'b0001;
            else
                r_first_priority_reg[gen_i] <= r_first_priority[gen_i];
        end

        //得到仲裁结果后即对输入级的四个2x2模块的配置
        for(m = 0 ; m < 4 ; m = m + 1)begin
            always @(*)begin
                if(i_rst || r_grant_valid)
                    ro_switch_grant[gen_i][m] = P_BAR;
                else if(gen_i == 0)
                    ro_switch_grant[gen_i][m] = P_BAR;
                else if(gen_i > 0 && r_req_4x4module_out0[gen_i-1][m] && !w_grant_4x4module_out0[gen_i-1][m] && w_grant_4x4module_out_valid[gen_i-1][0])
                    ro_switch_grant[gen_i][m] = ~ro_switch_grant[gen_i-1][m];
                else if(gen_i > 0 && r_req_4x4module_out1[gen_i-1][m] && !w_grant_4x4module_out1[gen_i-1][m] && w_grant_4x4module_out_valid[gen_i-1][1])
                    ro_switch_grant[gen_i][m] = ~ro_switch_grant[gen_i-1][m];
                else if(gen_i > 0 && r_req_4x4module_out2[gen_i-1][m] && !w_grant_4x4module_out2[gen_i-1][m] && w_grant_4x4module_out_valid[gen_i-1][2])
                    ro_switch_grant[gen_i][m] = ~ro_switch_grant[gen_i-1][m];
                else if(gen_i > 0 && r_req_4x4module_out3[gen_i-1][m] && !w_grant_4x4module_out3[gen_i-1][m] && w_grant_4x4module_out_valid[gen_i-1][3])
                    ro_switch_grant[gen_i][m] = ~ro_switch_grant[gen_i-1][m];
                else
                    ro_switch_grant[gen_i][m] = ro_switch_grant[gen_i-1][m];
            end
            always @(posedge i_clk)begin
                if(i_rst)
                    ro_switch_grant_reg[gen_i][m] <= 'd0;
                else
                    ro_switch_grant_reg[gen_i][m] <= ro_switch_grant[gen_i][m];
            end
        end
    
        for(m = 0 ; m < 4 ; m = m + 1)begin
            always @(*)begin
                if(i_rst || r_grant_valid)begin
                    r_req_4x4module_out0[gen_i][m] = 'd0;
                    r_req_4x4module_out1[gen_i][m] = 'd0;
                    r_req_4x4module_out2[gen_i][m] = 'd0;
                    r_req_4x4module_out3[gen_i][m] = 'd0;
                end
                else if(i_8x8in_valid && gen_i == 0)begin
                    r_req_4x4module_out0[gen_i][m] = (dstOf_4x4port[2*m] == 0) ? 1'b1 : 1'b0;
                    r_req_4x4module_out1[gen_i][m] = (dstOf_4x4port[2*m] == 1) ? 1'b1 : 1'b0;
                    r_req_4x4module_out2[gen_i][m] = (dstOf_4x4port[2*m] == 2) ? 1'b1 : 1'b0;
                    r_req_4x4module_out3[gen_i][m] = (dstOf_4x4port[2*m] == 3) ? 1'b1 : 1'b0;
                end
                else if(r_config_continue[gen_i - 1] && gen_i > 0)begin
                    r_req_4x4module_out0[gen_i][m] = (ro_switch_grant[gen_i][m] == P_BAR) ? (dstOf_4x4port[2*m] == 0) : (dstOf_4x4port[2*m + 1] == 0);
                    r_req_4x4module_out1[gen_i][m] = (ro_switch_grant[gen_i][m] == P_BAR) ? (dstOf_4x4port[2*m] == 1) : (dstOf_4x4port[2*m + 1] == 1);
                    r_req_4x4module_out2[gen_i][m] = (ro_switch_grant[gen_i][m] == P_BAR) ? (dstOf_4x4port[2*m] == 2) : (dstOf_4x4port[2*m + 1] == 2);
                    r_req_4x4module_out3[gen_i][m] = (ro_switch_grant[gen_i][m] == P_BAR) ? (dstOf_4x4port[2*m] == 3) : (dstOf_4x4port[2*m + 1] == 3);         
                end
                else if(!r_config_continue[gen_i - 1] && gen_i > 0) begin
                    r_req_4x4module_out0[gen_i][m] = r_req_4x4module_out0[gen_i-1][m];
                    r_req_4x4module_out1[gen_i][m] = r_req_4x4module_out1[gen_i-1][m];
                    r_req_4x4module_out2[gen_i][m] = r_req_4x4module_out2[gen_i-1][m];
                    r_req_4x4module_out3[gen_i][m] = r_req_4x4module_out3[gen_i-1][m];
                end
                else begin
                    r_req_4x4module_out0[gen_i][m] = r_req_4x4module_out0_reg[gen_i][m];
                    r_req_4x4module_out1[gen_i][m] = r_req_4x4module_out1_reg[gen_i][m];
                    r_req_4x4module_out2[gen_i][m] = r_req_4x4module_out2_reg[gen_i][m];
                    r_req_4x4module_out3[gen_i][m] = r_req_4x4module_out3_reg[gen_i][m];                    
                end
            end
            always @(posedge i_clk or posedge i_rst) begin
                if(i_rst)begin
                    r_req_4x4module_out0_reg[gen_i][m] <= 'd0;
                    r_req_4x4module_out1_reg[gen_i][m] <= 'd0;
                    r_req_4x4module_out2_reg[gen_i][m] <= 'd0;
                    r_req_4x4module_out3_reg[gen_i][m] <= 'd0;
                end
                else begin
                    r_req_4x4module_out0_reg[gen_i][m] <= r_req_4x4module_out0[gen_i][m];
                    r_req_4x4module_out1_reg[gen_i][m] <= r_req_4x4module_out1[gen_i][m];
                    r_req_4x4module_out2_reg[gen_i][m] <= r_req_4x4module_out2[gen_i][m];
                    r_req_4x4module_out3_reg[gen_i][m] <= r_req_4x4module_out3[gen_i][m];
                end
            end
        end

        //请求仲裁有效信号
        always @(*)begin
            if(i_rst || r_grant_valid)
                r_req_4x4module_out_valid[gen_i] = 'd0;
            else if(i_8x8in_valid && gen_i == 0)
                r_req_4x4module_out_valid[gen_i] = 'd1;
            else if(r_config_continue[gen_i - 1] && gen_i > 0)
                r_req_4x4module_out_valid[gen_i] = 'd1;
            else
                r_req_4x4module_out_valid[gen_i] = 'd0;
        end

        always @(*)begin
            if(i_rst || r_grant_valid)
                ro_grant_valid[gen_i] = 'd0;
            else if(&w_grant_4x4module_out_valid[gen_i])
                ro_grant_valid[gen_i] = 'd1;
            else
                ro_grant_valid[gen_i] = 'd0;
        end

        //继续仲裁
        always @(*)begin
            if(i_rst || r_grant_valid)
                r_config_continue[gen_i] = 'd0;
            else if(ro_grant_valid[gen_i] && (ro_4x4_req_1[gen_i][1:0] + ro_4x4_req_1[gen_i][3:2] + ro_4x4_req_1[gen_i][5:4] + ro_4x4_req_1[gen_i][7:6] != 'd6))
                r_config_continue[gen_i] = 'd1;
            else if((ro_4x4_req_1[gen_i][1:0] + ro_4x4_req_1[gen_i][3:2] + ro_4x4_req_1[gen_i][5:4] + ro_4x4_req_1[gen_i][7:6] == 'd6) 
                    && ((ro_4x4_req_1[gen_i][1:0] == ro_4x4_req_1[gen_i][3:2]) || (ro_4x4_req_1[gen_i][1:0] == ro_4x4_req_1[gen_i][5:4])
                    ||  (ro_4x4_req_1[gen_i][1:0] == ro_4x4_req_1[gen_i][7:6]) || (ro_4x4_req_1[gen_i][3:2] == ro_4x4_req_1[gen_i][5:4])
                    ||  (ro_4x4_req_1[gen_i][3:2] == ro_4x4_req_1[gen_i][7:6]) || (ro_4x4_req_1[gen_i][5:4] == ro_4x4_req_1[gen_i][7:6])))
                r_config_continue[gen_i] = 'd1;
            else
                r_config_continue[gen_i] = r_config_continue_reg[gen_i];
        end

        always @(posedge i_clk or posedge i_rst)begin
            if(i_rst)
                r_config_continue_reg[gen_i] <= 'd0;
            else
                r_config_continue_reg[gen_i] <= r_config_continue[gen_i];
        end

        //记录仲裁次数
        always @(*)begin
            if(i_rst || r_grant_valid)
                r_config_cnt[gen_i] = 'd0;
            else if(gen_i == 0)
                r_config_cnt[gen_i] = 'd0;
            else if(gen_i > 0 && r_config_continue[gen_i - 1] && ro_grant_valid[gen_i - 1])
                r_config_cnt[gen_i] = r_config_cnt[gen_i - 1] + 1;
            else if(gen_i > 0 && !r_config_continue[gen_i - 1] && ro_grant_valid[gen_i - 1])
                r_config_cnt[gen_i] = r_config_cnt[gen_i - 1];
            else
                r_config_cnt[gen_i] = r_config_cnt[gen_i - 1];
        end
        always @(posedge i_clk or posedge i_rst)begin
            if(i_rst)
                r_config_cnt_reg[gen_i] <= 'd0;
            else
                r_config_cnt_reg[gen_i] <= r_config_cnt[gen_i];
        end

        //更新中间级4x4模块的请求状态
        for(m = 0 ; m < 4 ; m = m + 1)begin
            always @(*)begin
                if(i_rst || r_grant_valid)
                    ro_4x4_req_1[gen_i][2*m +: 2] = 'd0;
                else if(ro_switch_grant[gen_i][m] == P_BAR && ro_grant_valid[gen_i])
                    ro_4x4_req_1[gen_i][2*m +: 2] = dstOf_4x4port[2*m];
                else if(ro_switch_grant[gen_i][m] != P_BAR && ro_grant_valid[gen_i])
                    ro_4x4_req_1[gen_i][2*m +: 2] = dstOf_4x4port[2*m + 1];
                else
                    ro_4x4_req_1[gen_i][2*m +: 2] = ro_4x4_req_1_reg[gen_i][2*m +: 2];
            end
            always @(posedge i_clk)begin
                ro_4x4_req_1_reg[gen_i][2*m +: 2] <= ro_4x4_req_1[gen_i][2*m +: 2];
            end

            always @(*)begin
                if(i_rst || r_grant_valid)
                    ro_4x4_req_2[gen_i][2*m +: 2] = 'd0;
                else if(ro_switch_grant[gen_i][m] == P_BAR && ro_grant_valid[gen_i])
                    ro_4x4_req_2[gen_i][2*m +: 2] = dstOf_4x4port[2*m + 1];
                else if(ro_switch_grant[gen_i][m] != P_BAR && ro_grant_valid[gen_i])
                    ro_4x4_req_2[gen_i][2*m +: 2] = dstOf_4x4port[2*m];
                else
                    ro_4x4_req_2[gen_i][2*m +: 2] = ro_4x4_req_2_reg[gen_i][2*m +: 2];
            end
            always @(posedge i_clk)begin
                ro_4x4_req_2_reg[gen_i][2*m +: 2] <= ro_4x4_req_2[gen_i][2*m +: 2];
            end

        end

        FIXED_Arbiter#(
            .P_CHANNEL_NUM      (4                                      )
        )FIXED_Arbiter_u0(      
            .i_clk              (i_clk                                  ),
            .i_rst              (i_rst                                  ),
            .i_req              (r_req_4x4module_out0[gen_i]            ),
            .i_first_priority   (r_first_priority[gen_i]                ),
            .i_req_valid        (r_req_4x4module_out_valid[gen_i]       ),
            .o_grant            (w_grant_4x4module_out0[gen_i]          ),
            .o_grant_valid      (w_grant_4x4module_out_valid[gen_i][0]  )  
        );
        FIXED_Arbiter#(
            .P_CHANNEL_NUM      (4                          )
        )FIXED_Arbiter_u1(
            .i_clk              (i_clk                      ),
            .i_rst              (i_rst                      ),
            .i_req              (r_req_4x4module_out1[gen_i]            ),
            .i_first_priority   (r_first_priority[gen_i]                ),
            .i_req_valid        (r_req_4x4module_out_valid[gen_i]       ),
            .o_grant            (w_grant_4x4module_out1[gen_i]          ),
            .o_grant_valid      (w_grant_4x4module_out_valid[gen_i][1]  ) 
        );
        FIXED_Arbiter#(
            .P_CHANNEL_NUM      (4                          )
        )FIXED_Arbiter_u2(
            .i_clk              (i_clk                      ),
            .i_rst              (i_rst                      ),
            .i_req              (r_req_4x4module_out2[gen_i]            ),
            .i_first_priority   (r_first_priority[gen_i]                ),
            .i_req_valid        (r_req_4x4module_out_valid[gen_i]       ),
            .o_grant            (w_grant_4x4module_out2[gen_i]          ),
            .o_grant_valid      (w_grant_4x4module_out_valid[gen_i][2]  ) 
        );
        FIXED_Arbiter#(
            .P_CHANNEL_NUM      (4                          )
        )FIXED_Arbiter_u3(
            .i_clk              (i_clk                      ),
            .i_rst              (i_rst                      ),
            .i_req              (r_req_4x4module_out3[gen_i]            ),
            .i_first_priority   (r_first_priority[gen_i]                ),
            .i_req_valid        (r_req_4x4module_out_valid[gen_i]       ),
            .o_grant            (w_grant_4x4module_out3[gen_i]          ),
            .o_grant_valid      (w_grant_4x4module_out_valid[gen_i][3]  ) 
        );
    end
endgenerate

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
        ri_8x8in_valid <= 'd0;
        ri_8x8in_valid_1d <= 'd0;
        ri_8x8in_req <= 'd0;     
    end
    else begin
        ri_8x8in_valid <= i_8x8in_valid; 
        ri_8x8in_valid_1d <= ri_8x8in_valid;
        ri_8x8in_req <= i_8x8in_req;      
    end
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_grant_valid_1d <= 'd0;
    else if(ro_grant_valid[r_config_cnt[P_INTER - 1]] && !r_config_continue[r_config_cnt[P_INTER - 1]])
        ro_grant_valid_1d  <= ro_grant_valid[r_config_cnt[P_INTER - 1]];
    else
        ro_grant_valid_1d <= 'd0;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
        r_switch_grant <= 'd0;
        r_grant_valid  <= 'd0;
    end
    else if(!r_config_continue[r_config_cnt[P_INTER - 1]] && ro_grant_valid[r_config_cnt[P_INTER - 1]])begin
        r_switch_grant <= ro_switch_grant[r_config_cnt[P_INTER - 1]];
        r_grant_valid  <= ro_grant_valid[r_config_cnt[P_INTER - 1]] ;
    end
    else begin
        r_switch_grant <= 'd0;
        r_grant_valid  <= 'd0;
    end
end

always @(*)begin
    if(i_rst)
        ro_4x4_valid = 'd0;
    else if(!r_config_continue[r_config_cnt[P_INTER - 1]] && ro_grant_valid[r_config_cnt[P_INTER - 1]])
        ro_4x4_valid = 'd1;
    else
        ro_4x4_valid = 'd0;
end

always @(posedge i_clk)begin
    ro_4x4_valid_1d <= ro_4x4_valid;
end

always @(posedge i_clk)begin
    ro_4x4_req_1_1d <= ro_4x4_req_1 [r_config_cnt[P_INTER - 1]];
    ro_4x4_req_2_1d <= ro_4x4_req_2 [r_config_cnt[P_INTER - 1]];
end


//同时根据输入级模块的配置结果，可以得出输出级模块的输出请求，从而配置输出级模块的4个2x2模块
integer t;

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
        for(t = 0 ; t < 4 ; t = t + 1)begin
            dstOf_8x8endport[2*t] <= 'd0;
            dstOf_8x8endport[2*t + 1] <= 'd0;
        end
    end   
    else if(ro_grant_valid[r_config_cnt[P_INTER - 1]] && (!r_config_continue[r_config_cnt[P_INTER - 1]]))begin
        for(t = 0 ; t < 4 ; t = t + 1)begin
            if(ro_switch_grant[r_config_cnt[P_INTER - 1]][t] == P_BAR)begin
                if(dstOf_4x4port[2*t] == 0)
                    dstOf_8x8endport[0] <= dstOf_8x8port[2*t];            
                else if(dstOf_4x4port[2*t] == 1)
                    dstOf_8x8endport[2] <= dstOf_8x8port[2*t];             
                else if(dstOf_4x4port[2*t] == 2)
                    dstOf_8x8endport[4] <= dstOf_8x8port[2*t];          
                else if(dstOf_4x4port[2*t] == 3)
                    dstOf_8x8endport[6] <= dstOf_8x8port[2*t];   
            end
            else begin
                if(dstOf_4x4port[2*t + 1] == 0)
                    dstOf_8x8endport[0] <= dstOf_8x8port[2*t + 1];            
                else if(dstOf_4x4port[2*t + 1] == 1)
                    dstOf_8x8endport[2] <= dstOf_8x8port[2*t + 1];             
                else if(dstOf_4x4port[2*t + 1] == 2)
                    dstOf_8x8endport[4] <= dstOf_8x8port[2*t + 1];          
                else if(dstOf_4x4port[2*t + 1] == 3)
                    dstOf_8x8endport[6] <= dstOf_8x8port[2*t + 1];
            end
        end
    end
    else begin
        for(t = 0 ; t < 4 ; t = t + 1)begin
            dstOf_8x8endport[2*t] <= 'd0;
            dstOf_8x8endport[2*t + 1] <= 'd0;
        end           
    end   
end

//生成输出级模块的配置请求
integer out_n;
always @(*)begin
    if(i_rst)begin
        for(out_n = 0 ; out_n < P_PORTNUM ; out_n = out_n + 1)begin
            ro_8x8out_req[P_DSTWIDTH*out_n +: P_DSTWIDTH] = 'd0;
        end
    end
    else if(ro_grant_valid_1d)begin
        for(out_n = 0 ; out_n < P_PORTNUM ; out_n = out_n + 1)begin
            ro_8x8out_req[P_DSTWIDTH*out_n +: P_DSTWIDTH] = dstOf_8x8endport[out_n];
        end        
    end
    else begin
        for(out_n = 0 ; out_n < P_PORTNUM ; out_n = out_n + 1)begin
            ro_8x8out_req[P_DSTWIDTH*out_n +: P_DSTWIDTH] = ro_8x8out_req_reg[P_DSTWIDTH*out_n +: P_DSTWIDTH];
        end        
    end
end

always @(posedge i_clk)begin
    ro_8x8out_req_reg <= ro_8x8out_req;
end


endmodule
