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
reg  [P_SWITCHNUM - 1:0]            r_switch_grant      ;
reg                                 r_grant_valid       ;
reg  [P_SWITCHNUM - 1:0]            ro_switch_grant     ;
reg                                 ro_grant_valid      ;
reg  [P_SWITCHNUM - 1:0]            ro_switch_grant_1d  ;
reg  [P_SWITCHNUM - 1:0]            ro_switch_grant_2d  ;
reg  [P_SWITCHNUM - 1:0]            ro_switch_grant_3d  ;
reg                                 ro_grant_valid_1d   ;
reg                                 ro_grant_valid_2d   ;
reg                                 ro_grant_valid_3d   ;
//通过第二个4x4模块后的配置结果，以此为最终结果

reg                                 r_config_continue   ;
reg  [2:0]                          r_config_cnt        ;

reg  [P_DSTWIDTH*P_PORTNUM - 1:0]   ro_8x8out_req       ;
reg                                 ro_8x8out_valid     ;
reg  [7 :0]                         ro_4x4_req_1        ;
reg  [7 :0]                         ro_4x4_req_2        ;
reg  [7 :0]                         ro_4x4_req_1_reg    ;
reg  [7 :0]                         ro_4x4_req_2_reg    ;
reg                                 ro_4x4_valid        ;

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
reg                     r_req_4x4module_out_valid       ;
reg  [3 :0]             r_first_priority                ;
reg  [3 :0]             r_req_4x4module_out0            ;
reg  [3 :0]             r_req_4x4module_out1            ;
reg  [3 :0]             r_req_4x4module_out2            ;
reg  [3 :0]             r_req_4x4module_out3            ;
reg  [3 :0]             r_req_4x4module_out0_reg        ;
reg  [3 :0]             r_req_4x4module_out1_reg        ;
reg  [3 :0]             r_req_4x4module_out2_reg        ;
reg  [3 :0]             r_req_4x4module_out3_reg        ;

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
reg  [3 :0]             r_grant_4x4module_out0          ;
reg  [3 :0]             r_grant_4x4module_out1          ;
reg  [3 :0]             r_grant_4x4module_out2          ;
reg  [3 :0]             r_grant_4x4module_out3          ;
reg  [3 :0]             r_grant_4x4module_out_valid     ;//指示授权有效信号

/***************component*************/
FIXED_Arbiter#(
    .P_CHANNEL_NUM      (4                          )
)FIXED_Arbiter_u0(
    .i_clk              (i_clk                      ),
    .i_rst              (i_rst                      ),
    .i_req              (r_req_4x4module_out0       ),
    .i_first_priority   (r_first_priority           ),
    .i_req_valid        (r_req_4x4module_out_valid  ),
    .o_grant            (w_grant_4x4module_out0     ),
    .o_grant_valid      (w_grant_4x4module_out_valid[0])  
);
FIXED_Arbiter#(
    .P_CHANNEL_NUM      (4                          )
)FIXED_Arbiter_u1(
    .i_clk              (i_clk                      ),
    .i_rst              (i_rst                      ),
    .i_req              (r_req_4x4module_out1       ),
    .i_first_priority   (r_first_priority           ),
    .i_req_valid        (r_req_4x4module_out_valid  ),
    .o_grant            (w_grant_4x4module_out1     ),
    .o_grant_valid      (w_grant_4x4module_out_valid[1]) 
);
FIXED_Arbiter#(
    .P_CHANNEL_NUM      (4                          )
)FIXED_Arbiter_u2(
    .i_clk              (i_clk                      ),
    .i_rst              (i_rst                      ),
    .i_req              (r_req_4x4module_out2       ),
    .i_first_priority   (r_first_priority           ),
    .i_req_valid        (r_req_4x4module_out_valid  ),
    .o_grant            (w_grant_4x4module_out2     ),
    .o_grant_valid      (w_grant_4x4module_out_valid[2]) 
);
FIXED_Arbiter#(
    .P_CHANNEL_NUM      (4                          )
)FIXED_Arbiter_u3(
    .i_clk              (i_clk                      ),
    .i_rst              (i_rst                      ),
    .i_req              (r_req_4x4module_out3       ),
    .i_first_priority   (r_first_priority           ),
    .i_req_valid        (r_req_4x4module_out_valid  ),
    .o_grant            (w_grant_4x4module_out3     ),
    .o_grant_valid      (w_grant_4x4module_out_valid[3])  
);

/***************assign****************/
assign o_switch_grant   = r_switch_grant    ;
assign o_grant_valid    = r_grant_valid     ;
assign o_8x8out_req     = ro_8x8out_req     ;
assign o_8x8out_valid   = ro_8x8out_valid   ;
assign o_4x4_req_1      = ro_4x4_req_1      ;
assign o_4x4_req_2      = ro_4x4_req_2      ;
assign o_4x4_valid      = ro_4x4_valid      ;

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
//请求仲裁有效信号
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_req_4x4module_out_valid <= 'd0;
    else if(i_8x8in_valid)
        r_req_4x4module_out_valid <= 'd1;
    else if(r_config_continue)
        r_req_4x4module_out_valid <= 'd1;
    else
        r_req_4x4module_out_valid <= 'd0;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_first_priority <= 'd0;
    else if(i_8x8in_valid)
        r_first_priority <= 'd1;
    else if(r_config_continue && (ro_switch_grant[0] != ro_switch_grant_1d[0]))
        r_first_priority <= 4'b0001;
    else if(r_config_continue && (ro_switch_grant[1] != ro_switch_grant_1d[1]))
        r_first_priority <= 4'b0010;
    else if(r_config_continue && (ro_switch_grant[2] != ro_switch_grant_1d[2]))
        r_first_priority <= 4'b0100;
    else if(r_config_continue && (ro_switch_grant[3] != ro_switch_grant_1d[3]))
        r_first_priority <= 4'b1000;
    else
        r_first_priority <= 'd0;
end

//仲裁请求
genvar k;
generate
    for(k = 0 ; k < 4 ; k = k+1)begin
        always @(*)begin
            if(i_rst)begin
                r_req_4x4module_out0[k] = 'd0;
                r_req_4x4module_out1[k] = 'd0;
                r_req_4x4module_out2[k] = 'd0;
                r_req_4x4module_out3[k] = 'd0;
            end
            else if(i_8x8in_valid)begin
                r_req_4x4module_out0[k] = (dstOf_4x4port[2*k] == 0) ? 1'b1 : 1'b0;
                r_req_4x4module_out1[k] = (dstOf_4x4port[2*k] == 1) ? 1'b1 : 1'b0;
                r_req_4x4module_out2[k] = (dstOf_4x4port[2*k] == 2) ? 1'b1 : 1'b0;
                r_req_4x4module_out3[k] = (dstOf_4x4port[2*k] == 3) ? 1'b1 : 1'b0;
            end
            else if(r_config_continue)begin
                r_req_4x4module_out0[k] = (ro_switch_grant[k] == P_BAR) ? (dstOf_4x4port[2*k] == 0) : (dstOf_4x4port[2*k + 1] == 0);
                r_req_4x4module_out1[k] = (ro_switch_grant[k] == P_BAR) ? (dstOf_4x4port[2*k] == 1) : (dstOf_4x4port[2*k + 1] == 1);
                r_req_4x4module_out2[k] = (ro_switch_grant[k] == P_BAR) ? (dstOf_4x4port[2*k] == 2) : (dstOf_4x4port[2*k + 1] == 2);
                r_req_4x4module_out3[k] = (ro_switch_grant[k] == P_BAR) ? (dstOf_4x4port[2*k] == 3) : (dstOf_4x4port[2*k + 1] == 3);         
            end
            else begin
                r_req_4x4module_out0[k] = r_req_4x4module_out0_reg[k];
                r_req_4x4module_out1[k] = r_req_4x4module_out1_reg[k];
                r_req_4x4module_out2[k] = r_req_4x4module_out2_reg[k];
                r_req_4x4module_out3[k] = r_req_4x4module_out3_reg[k];
            end
        end
        always @(posedge i_clk or posedge i_rst) begin
            if(i_rst)begin
                r_req_4x4module_out0_reg[k] = 'd0;
                r_req_4x4module_out1_reg[k] = 'd0;
                r_req_4x4module_out2_reg[k] = 'd0;
                r_req_4x4module_out3_reg[k] = 'd0;
            end
            else begin
                r_req_4x4module_out0_reg[k] = r_req_4x4module_out0[k];
                r_req_4x4module_out1_reg[k] = r_req_4x4module_out1[k];
                r_req_4x4module_out2_reg[k] = r_req_4x4module_out2[k];
                r_req_4x4module_out3_reg[k] = r_req_4x4module_out3[k];
            end
        end
    end
endgenerate

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
        r_grant_4x4module_out0 <= 'd0;
        r_grant_4x4module_out1 <= 'd0;
        r_grant_4x4module_out2 <= 'd0;
        r_grant_4x4module_out3 <= 'd0;
        r_grant_4x4module_out_valid <= 'd0;
    end
    else if(&w_grant_4x4module_out_valid)begin
        r_grant_4x4module_out0 <= w_grant_4x4module_out0;
        r_grant_4x4module_out1 <= w_grant_4x4module_out1;
        r_grant_4x4module_out2 <= w_grant_4x4module_out2;
        r_grant_4x4module_out3 <= w_grant_4x4module_out3;
        r_grant_4x4module_out_valid <= w_grant_4x4module_out_valid;
    end
    else begin
        r_grant_4x4module_out0 <= r_grant_4x4module_out0;
        r_grant_4x4module_out1 <= r_grant_4x4module_out1;
        r_grant_4x4module_out2 <= r_grant_4x4module_out2;
        r_grant_4x4module_out3 <= r_grant_4x4module_out3;
        r_grant_4x4module_out_valid <= 'd0;
    end
end

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
//得到仲裁结果后即对输入级的四个2x2模块的配置
genvar m;
generate
    for(m = 0 ; m < 4 ; m = m + 1)begin
        always @(posedge i_clk or posedge i_rst)begin
            if(i_rst)
                ro_switch_grant[m] <= P_BAR;
            else if(r_switch_grant)
                ro_switch_grant[m] <= P_BAR;
            else if(r_req_4x4module_out0[m] && !w_grant_4x4module_out0[m] && w_grant_4x4module_out_valid[0])
                ro_switch_grant[m] <= ~ro_switch_grant[m];
            else if(r_req_4x4module_out1[m] && !w_grant_4x4module_out1[m] && w_grant_4x4module_out_valid[1])
                ro_switch_grant[m] <= ~ro_switch_grant[m];
            else if(r_req_4x4module_out2[m] && !w_grant_4x4module_out2[m] && w_grant_4x4module_out_valid[2])
                ro_switch_grant[m] <= ~ro_switch_grant[m];
            else if(r_req_4x4module_out3[m] && !w_grant_4x4module_out3[m] && w_grant_4x4module_out_valid[3])
                ro_switch_grant[m] <= ~ro_switch_grant[m];
            else
                ro_switch_grant[m] <= ro_switch_grant[m];
        end
    end
endgenerate

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_grant_valid <= 'd0;
    else if(&w_grant_4x4module_out_valid)
        ro_grant_valid <= 'd1;
    else
        ro_grant_valid <= 'd0;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
        ro_switch_grant_1d <= 'd0;
        ro_switch_grant_2d <= 'd0;
        ro_switch_grant_3d <= 'd0;
        //ro_grant_valid_1d  <= 'd0;
        ro_grant_valid_2d  <= 'd0;
    end
    else begin
        ro_switch_grant_1d <= ro_switch_grant;
        //ro_grant_valid_1d  <= ro_grant_valid ;
        ro_switch_grant_2d <= ro_switch_grant_1d;
        ro_switch_grant_3d <= ro_switch_grant_2d;
        ro_grant_valid_2d  <= ro_grant_valid_1d;
    end
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_grant_valid_1d <= 'd0;
    else if(ro_grant_valid && !r_config_continue)
        ro_grant_valid_1d  <= ro_grant_valid;
    else
        ro_grant_valid_1d <= 'd0;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
        r_switch_grant <= 'd0;
        r_grant_valid  <= 'd0;
    end
    else if(!r_config_continue && ro_grant_valid)begin
        r_switch_grant <= ro_switch_grant;
        r_grant_valid  <= ro_grant_valid ;
    end
    else begin
        r_switch_grant <= 'd0;
        r_grant_valid  <= 'd0;
    end
end

//通过输入级的模块配置结果，即可向2个4x4模块下发配置请求ro_4x4_req_1、ro_4x4_req_2

always @(posedge i_clk)begin
    ro_4x4_req_1_reg <= ro_4x4_req_1;
    ro_4x4_req_2_reg <= ro_4x4_req_2;
end

genvar n;
generate
    for(n = 0 ; n < 4 ; n = n + 1)begin
        always @(*)begin
            if(i_rst)
                ro_4x4_req_1[2*n +: 2] = 'd0;
            else if(ro_switch_grant[n] == P_BAR && ro_grant_valid)
                ro_4x4_req_1[2*n +: 2] = dstOf_4x4port[2*n];
            else if(ro_switch_grant[n] != P_BAR && ro_grant_valid)
                ro_4x4_req_1[2*n +: 2] = dstOf_4x4port[2*n + 1];
            else
                ro_4x4_req_1[2*n +: 2] = ro_4x4_req_1_reg[2*n +: 2];
        end
    end

    for(n = 0 ; n < 4 ; n = n + 1)begin
        always @(*)begin
            if(i_rst)
                ro_4x4_req_2[2*n +: 2] = 'd0;
            else if(ro_switch_grant[n] == P_BAR && ro_grant_valid)
                ro_4x4_req_2[2*n +: 2] = dstOf_4x4port[2*n + 1];
            else if(ro_switch_grant[n] != P_BAR && ro_grant_valid)
                ro_4x4_req_2[2*n +: 2] = dstOf_4x4port[2*n];
            else
                ro_4x4_req_2[2*n +: 2] = ro_4x4_req_2_reg[2*n +: 2];
        end
    end
endgenerate
//同时根据输入级模块的配置结果，可以得出输出级模块的输出请求，从而配置输出级模块的4个2x2模块
integer t;

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
        for(t = 0 ; t < 4 ; t = t + 1)begin
            dstOf_8x8endport[2*t] <= 'd0;
            dstOf_8x8endport[2*t + 1] <= 'd0;
        end
    end   
    else if(ro_grant_valid && (!r_config_continue))begin
        for(t = 0 ; t < 4 ; t = t + 1)begin
            if(ro_switch_grant[t] == P_BAR)begin
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



always @(*)begin
    if(i_rst)
        ro_4x4_valid = 'd0;
    else if(!r_config_continue && ro_grant_valid)
        ro_4x4_valid = 'd1;
    else
        ro_4x4_valid = 'd0;
end
//继续仲裁
always @(*)begin
    if(i_rst)
        r_config_continue = 'd0;
    else if(ro_grant_valid && (ro_4x4_req_1[1:0] + ro_4x4_req_1[3:2] + ro_4x4_req_1[5:4] + ro_4x4_req_1[7:6] != 'd6))
        r_config_continue = 'd1;
    else
        r_config_continue = 'd0;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_config_cnt <= 'd0;
    else if(ro_grant_valid_1d && (ro_4x4_req_1[1:0] + ro_4x4_req_1[3:2] + ro_4x4_req_1[5:4] + ro_4x4_req_1[7:6] == 'd6))
        r_config_cnt <= 'd0;
    else if(ro_grant_valid_1d && (ro_4x4_req_1[1:0] + ro_4x4_req_1[3:2] + ro_4x4_req_1[5:4] + ro_4x4_req_1[7:6] != 'd6))
        r_config_cnt <= r_config_cnt + 'd1;
    else
        r_config_cnt <= r_config_cnt;
end
//生成输出级模块的配置请求
integer out_n;
always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
        for(out_n = 0 ; out_n < P_PORTNUM ; out_n = out_n + 1)begin
            ro_8x8out_req[P_DSTWIDTH*out_n +: P_DSTWIDTH] <= 'd0;
        end
    end
    else if(ro_grant_valid_1d)begin
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
    else if(ro_grant_valid_1d)
        ro_8x8out_valid <= 'd1;
    else
        ro_8x8out_valid <= 'd0;
end

endmodule
