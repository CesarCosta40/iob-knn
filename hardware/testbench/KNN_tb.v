`timescale 1ns/1ps
`include "iob_lib.vh"
`include "interconnect.vh"

module knn_tb;

   localparam PER=10;

   `CLOCK(clk, PER)
   `RESET(rst, 7, 10)
   
   `SIGNAL(DATA_IN, 32)
   `SIGNAL_OUT(DATA0_OUT, 8)
   `SIGNAL_OUT(DATA1_OUT, 8)
   `SIGNAL_OUT(DATA2_OUT, 8)
   `SIGNAL_OUT(DATA3_OUT, 8)
   `SIGNAL(ready, 1)

   integer i;

   initial begin
`ifdef VCD
      $dumpfile("knn.vcd");
      $dumpvars();
`endif
      ready=0;
      DATA_IN=0;
      @(posedge rst);
      @(negedge rst);

      for (i=1; i<100; i=i+1) begin
         if(i%5==0)
          ready=1;
        else
          ready=0;
         if (ready==1)
          #1 DATA_IN=100-i;

      

         @(posedge clk) #1
         if (ready==1)
         $display("DATA0_OUT : %d , DATA1_OUT : %d , DATA2_OUT : %d , DATA3_OUT : %d\n",DATA0_OUT, DATA1_OUT, DATA2_OUT, DATA3_OUT);
      end

      @(posedge clk) #100

      $finish;
   end

   //instantiate knn core
   /*knn_core knn0
     (
      .KNN_ENABLE(KNN_ENABLE),
      .KNN_DATA_IN(KNN_DATA_IN),
      .KNN_DATA_OUT(KNN_DATA_OUT),
      .clk(clk),
      .rst(rst)
      );
   */
    
   sorter sorter0
      (
        .rst(rst),
        .clk(clk),
        .ready(ready),
        .DATA_IN(DATA_IN),
        .DATA0_OUT(DATA0_OUT),
        .DATA1_OUT(DATA1_OUT),
        .DATA2_OUT(DATA2_OUT),
        .DATA3_OUT(DATA3_OUT)
      );
      
      
      /* dist_calc d0
   (
    .DATA_X1(DATA_X1),
    .DATA_X2(DATA_X2),
    .DATA_Y1(DATA_Y1),
    .DATA_Y2(DATA_Y2),
    .DATA_OUT(DATA_OUT)
   );
  */

endmodule
