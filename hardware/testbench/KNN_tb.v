`timescale 1ns/1ps
`include "iob_lib.vh"
`include "interconnect.vh"

module knn_tb;

   localparam PER=10;

   `CLOCK(clk, PER)
   `RESET(rst, 7, 10)
   `SIGNAL(KNN_ENABLE, 1)
   `SIGNAL(KNN_DATA_IN, 32)

   `SIGNAL(DATA_X1, 32)
   `SIGNAL(DATA_X2, 32)
   `SIGNAL(DATA_Y1, 32)
   `SIGNAL(DATA_Y2, 32)

   `SIGNAL_OUT(KNN_DATA_OUT, 32)

   `SIGNAL_OUT(DATA_OUT, 32)

   integer i;

   initial begin
`ifdef VCD
      $dumpfile("knn.vcd");
      $dumpvars();
`endif
      KNN_ENABLE = 0;
      KNN_DATA_IN = 0;

      @(posedge rst);
      @(negedge rst);
      @(posedge clk) #1 KNN_ENABLE = 1;
      @(posedge clk) #10 KNN_DATA_IN = 69;

      if( KNN_DATA_OUT == 69)
        $display("Test passed");
      else
        $display("Test failed: expecting knn value 69 but got %d", KNN_DATA_OUT);


      for (i=1; i<10; i=i+1) begin
         @(posedge clk) #1
         DATA_X1=i;
         DATA_X2=i*2;
         DATA_Y1=i;
         DATA_Y2=i*2;
         $display("%d -> DATA_X1: %d , DATA_X2: %d , Dist: %d",i, DATA_X1, DATA_X2, DATA_OUT);
      end

      @(posedge clk) #100

      $finish;
   end

   //instantiate knn core
   knn_core knn0
     (
      .KNN_ENABLE(KNN_ENABLE),
      .KNN_DATA_IN(KNN_DATA_IN),
      .KNN_DATA_OUT(KNN_DATA_OUT),
      .clk(clk),
      .rst(rst)
      );

   dist_calc d0
   (
    .DATA_X1(DATA_X1),
    .DATA_X2(DATA_X2),
    .DATA_Y1(DATA_Y1),
    .DATA_Y2(DATA_Y2),
    .DATA_OUT(DATA_OUT)
   );


endmodule
