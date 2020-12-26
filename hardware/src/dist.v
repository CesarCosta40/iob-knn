`timescale 1ns/1ps
`include "iob_lib.vh"

module dist_calc
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
   `OUTPUT(DATA_OUT,W+1)
   );


   `SIGNAL_SIGNED(sub1, W)
   `SIGNAL_SIGNED(sub2, W)
   `SIGNAL_SIGNED(sub1_int, W)
   `SIGNAL_SIGNED(sub2_int, W)
   `SIGNAL(sqr1, W)
   `SIGNAL(sqr2, W)
   `SIGNAL(sqr1_int, W)
   `SIGNAL(sqr2_int, W)
   `SIGNAL(result, W+1)
   `SIGNAL2OUT(DATA_OUT, result) //connect internal result to output


   //registos pipeline para separar as operações
   `REG_RE(clk, rst, 32'H00000000 , 1'b1, sub1_int , sub1)
   `REG_RE(clk, rst, 32'H00000000 , 1'b1, sub2_int , sub2)
   `REG_RE(clk, rst, 32'H00000000 , 1'b1, sqr1_int , sqr1)
   `REG_RE(clk, rst, 32'H00000000 , 1'b1, sqr2_int , sqr2)


   `COMB begin

   sub1 = DATA_X1 - DATA_X2;
   sub2 = DATA_Y1 - DATA_Y2;

   sqr1 = sub1_int * sub1_int;
   sqr2 = sub2_int * sub2_int;

   result = sqr1_int + sqr2_int;

   end

endmodule
