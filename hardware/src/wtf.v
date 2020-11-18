`timescale 1ns/1ps
`include "iob_lib.vh"

module dist_calc
  #(
    parameter W=32
    )
  (
   `INPUT(x_a,W),
   `INPUT(x_b,W),
   `INPUT(y_a,W),
   `INPUT(y_b,W),
   `OUTPUT(d,W)
   );

   
   `SIGNAL(sub1, W) 
   `SIGNAL(sub2, W) 
   `SIGNAL(sqr1, W)
   `SIGNAL(sqr2, W)
   `SIGNAL(result, W)
   `SIGNAL2OUT(d, result) //connect internal result to output


   `COMB begin
   
   sub1 = x_a - x_b;
   sub2 = y_a - y_b;
   sqr1 = sub1 * sub1;
   sqr2 = sub2 * sub2;
   result = sqr1 + sqr2;
   
   end
   
endmodule
