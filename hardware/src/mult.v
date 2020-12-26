`timescale 1ns/1ps
`include "iob_lib.vh"

module mult
#(
  parameter W=32
)
(
 input signed [(W/2)-1:0] a,
 `OUTPUT(DATA_OUT,W)
);

 `SIGNAL(result, W)
 `SIGNAL2OUT(DATA_OUT, result) //connect internal result to output

 `COMB begin
   result = a * a;
  end


endmodule
