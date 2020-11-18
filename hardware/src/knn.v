`timescale 1ns/1ps
`include "iob_lib.vh"

module knn_core
  #(
    parameter DATA_W = 32
    )
   (
    `INPUT(KNN_ENABLE, 1),    
    `INPUT(KNN_DATA_IN, DATA_W),
    `INPUT(clk, 1),
    `INPUT(rst, 1),
    `OUTPUT(KNN_DATA_OUT, DATA_W)
    );

    `SIGNAL2OUT(KNN_DATA_OUT, KNN_DATA_IN)
      
endmodule

