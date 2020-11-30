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
   `OUTPUT(DATA_OUT,W)
   );


   `SIGNAL_SIGNED(sub1, W)
   `SIGNAL_SIGNED(sub2, W)
   `SIGNAL(sqr1, W)
   `SIGNAL(sqr2, W)
   `SIGNAL(result, W)
   `SIGNAL2OUT(DATA_OUT, result) //connect internal result to output


   `COMB begin

   sub1 = DATA_X1 - DATA_X2;
   sub2 = DATA_Y1 - DATA_Y2;
   sqr1 = sub1 * sub1;
   sqr2 = sub2 * sub2;
   result = sqr1 + sqr2;

   end

endmodule
