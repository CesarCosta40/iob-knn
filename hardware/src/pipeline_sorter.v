`timescale 1ns/1ps
`include "iob_lib.vh"

module pipeline_sorter
  #(
    parameter W=32,
    parameter HW_K=10
  )
    (
     input signed [(W/2)-1:0] DATA_X1,//`INPUT(DATA_X1,W/2),
     input signed [(W/2)-1:0] DATA_X2,//`INPUT(DATA_X2,W/2),
     input signed [(W/2)-1:0] DATA_Y1,//`INPUT(DATA_Y1,W/2),
     input signed [(W/2)-1:0] DATA_Y2,//`INPUT(DATA_Y2,W/2),
     `INPUT(rst,1),
     `INPUT(clk,1),
     `INPUT(valid,1),
     `INPUT(DONE, 1),
     input [W/2-1:0] SEL,
     output [W/2-1:0] DATA_OUT,
     input signed [W:0] DIST_EXT_IN,
     output signed [W:0] DIST_EXT_OUT,
     input [W/2-1:0] idx_cnt_ext_in,
     output [W/2-1:0] idx_cnt_ext_out,
     input [1:0] series_enable,
     input [1:0] cn_in,
     output [1:0] cn_out
    );


    `SIGNAL(DIST_INT, W+1)
    `SIGNAL(DIST_IN_INT, W+1)
    `SIGNAL(valid_int1, 1)
    `SIGNAL(valid_int2, 1)
    `SIGNAL(valid_int3, 1)
    `SIGNAL(valid_int4, 1)
    `SIGNAL(DONE_INT1, 1)
    `SIGNAL(DONE_INT2, 1)
    `SIGNAL(DONE_INT3, 1)
    `SIGNAL(DONE_INT4, 1)


    //atrasos dos sinais valid  e DONE por causa do pipeline do dist_calc
    `REG_RE(clk, rst, 1'b0 , 1'b1, valid_int1 , valid)
    `REG_RE(clk, rst, 1'b0 , 1'b1, valid_int2 , valid_int1)
    `REG_RE(clk, rst, 1'b0 , 1'b1, valid_int3 , valid_int2)
    `REG_RE(clk, rst, 1'b0 , 1'b1, valid_int4 , valid_int3)

    `REG_RE(clk, rst, 1'b1 , 1'b1, DONE_INT1 , DONE)
    `REG_RE(clk, rst, 1'b1 , 1'b1, DONE_INT2 , DONE_INT1)
    `REG_RE(clk, rst, 1'b1 , 1'b1, DONE_INT3 , DONE_INT2)
    `REG_RE(clk, rst, 1'b1 , 1'b1, DONE_INT4 , DONE_INT3)

    `REG_RE(clk, rst, 32'H00000000 , 1'b1, DIST_IN_INT , DIST_INT)


   dist_calc dist_calc0
   (
     .DATA_X1(DATA_X1),
     .DATA_X2(DATA_X2),
     .DATA_Y1(DATA_Y1),
     .DATA_Y2(DATA_Y2),
     .rst(rst),
     .clk(clk),
     .valid(valid),
     .DATA_OUT(DIST_INT)
   );


   sorter #(.HW_K(HW_K)) sorter0
   (
     .rst(rst),
     .clk(clk),
     .valid(valid_int4),
     .DONE(DONE_INT4),
     .SEL(SEL),
     .DIST(DIST_IN_INT),
     .DATA_OUT(DATA_OUT),
     .DIST_EXT_IN(DIST_EXT_IN),
     .DIST_EXT_OUT(DIST_EXT_OUT),
     .idx_cnt_ext_in(idx_cnt_ext_in),
     .idx_cnt_ext_out(idx_cnt_ext_out),
     .series_enable(series_enable),
     .cn_in(cn_in),
     .cn_out(cn_out)
   );


endmodule
