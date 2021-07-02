//////////////////////////////////////////////////////////////////////////////////
//  ov5640 lcd display                                                          //
//                                                                              //
//  Author: meisq                                                               //
//          msq@qq.com                                                          //
//          ALINX(shanghai) Technology Co.,Ltd                                  //
//          heijin                                                              //
//     WEB: http://www.alinx.cn/                                                //
//     BBS: http://www.heijin.org/                                              //
//                                                                              //
//////////////////////////////////////////////////////////////////////////////////
//                                                                              //
// Copyright (c) 2017,ALINX(shanghai) Technology Co.,Ltd                        //
//                    All rights reserved                                       //
//                                                                              //
// This source file may be used and distributed without restriction provided    //
// that this copyright statement is not removed from the file and that any      //
// derivative work contains the original copyright notice and the associated    //
// disclaimer.                                                                  //
//                                                                              //
//////////////////////////////////////////////////////////////////////////////////

//================================================================================
//   Description:  pwm model
//   pwm out period = frequency(pwm_out) * (2 ** N) / frequency(clk);
//
//================================================================================
//  Revision History:
//  Date          By            Revision    Change Description
//--------------------------------------------------------------------------------
//  2017/5/3     meisq          1.0         Original
//********************************************************************************/
`timescale 1ns / 1ps
module ax_pwm
#(
	parameter N = 32 //pwm bit width 
)
(
    input         clk,
    input         rst,
    input[N - 1:0]period,
    input[N - 1:0]duty,
    input[N - 1:0]pwm_num,
    input[N - 1:0]pwm_num_en,
    input[N - 1:0]pwm_reg_set0,
    
    output        pwm_out 
    );
 
reg[N - 1:0] period_r;
reg[N - 1:0] duty_r;
reg[N - 1:0] period_cnt;
reg[N - 1:0] pwm_num_r;
reg[N - 1:0] pwm_state_r;
reg pwm_r;
reg data_in_d1;
reg data_in_d2;

assign pwm_out = pwm_r;

always@(posedge clk or posedge rst)
begin
    if(rst==1)
    begin
        period_r <= { N {1'b0} };
        duty_r <= { N {1'b0} };
    end
    else
    begin
        period_r <= period;
        duty_r   <= duty;
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1)
        period_cnt <= { N {1'b0} };
    else
        period_cnt <= period_cnt + period_r;
end

always @ (posedge clk,negedge rst)
begin
    if(rst==1)
    begin data_in_d1 <= 1'b0; data_in_d2 <= 1'b0; end 
    else
    begin data_in_d1 <= pwm_r; data_in_d2 <= data_in_d1;end 
end

always@(posedge clk or posedge rst)
begin
    if(rst==1)
        pwm_num_r <= 32'b0;
    else
    begin
        if(pwm_reg_set0==32'b0)
            if(~data_in_d1 &  data_in_d2)//ÅÐ¶ÏÏÂ½µÑØ
                pwm_num_r <= pwm_num_r + 32'b1;
            else
                pwm_num_r <= pwm_num_r;
         else
            pwm_num_r <= 32'b0;
                
    end
end
//assign raising_edge_detect = data_in_d1  & (~data_in_d2);//ÉÏÉýÑØ
//assign falling_edge_detect = ~data_in_d1 &  data_in_d2;//ÏÂ½µÑØ
//assign double_edge_detect  = data_in_d1 ^ data_in_d2;//Ë«±ßÑØ



always@(posedge clk or posedge rst)
begin
    if(rst==1)
    begin
        pwm_r <= 1'b0;
    end
    else
    begin

        if(pwm_num_en==32'b1)            
                if(period_cnt >= duty_r && pwm_num >= pwm_num_r)
                    pwm_r <= 1'b1;
                else
                    pwm_r <= 1'b0;           
        else       
            if(period_cnt >= duty_r)
                pwm_r <= 1'b1;
            else
                pwm_r <= 1'b0;         
    end
end

endmodule
