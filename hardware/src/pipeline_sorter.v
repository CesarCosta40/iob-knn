`timescale 1ns/1ps
`include "iob_lib.vh"

module pipeline_sorter
  #(
    parameter W=32
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
     input [3:0] SEL,
     output [W/4-1:0] DATA_OUT
     );


    `SIGNAL(DIST_INT, W+1)
    `SIGNAL(DIST_IN_INT, W+1)
    `SIGNAL(valid_int1, 1)
    `SIGNAL(valid_int2, 1)
    `SIGNAL(valid_int3, 1)
    `SIGNAL(DONE_INT1, 1)
    `SIGNAL(DONE_INT2, 1)
    `SIGNAL(DONE_INT3, 1)


    //atrasos dos sinais valid  e DONE por causa do pipeline do dist_calc
    `REG_RE(clk, rst, 1'b0 , 1'b1, valid_int1 , valid)
    `REG_RE(clk, rst, 1'b0 , 1'b1, valid_int2 , valid_int1)
    `REG_RE(clk, rst, 1'b0 , 1'b1, valid_int3 , valid_int2)

    `REG_RE(clk, rst, 1'b1 , 1'b1, DONE_INT1 , DONE)
    `REG_RE(clk, rst, 1'b1 , 1'b1, DONE_INT2 , DONE_INT1)
    `REG_RE(clk, rst, 1'b1 , 1'b1, DONE_INT3 , DONE_INT2)

    `REG_RE(clk, rst, 32'H00000000 , 1'b1, DIST_IN_INT , DIST_INT)


   dist_calc dist_calc0
   (
     .DATA_X1(DATA_X1),
     .DATA_X2(DATA_X2),
     .DATA_Y1(DATA_Y1),
     .DATA_Y2(DATA_Y2),
     .rst(rst),
     .clk(clk),
     .DATA_OUT(DIST_INT)
   );


   sorter sorter0
   (
     .rst(rst),
     .clk(clk),
     .valid(valid_int3),
     .DONE(DONE_INT3),
     .SEL(SEL),
     .DIST(DIST_IN_INT),
     .DATA_OUT(DATA_OUT)

   );


endmodule
