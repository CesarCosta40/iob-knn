`timescale 1ns/1ps
`include "iob_lib.vh"
`include "interconnect.vh"

module knn_tb;

   localparam PER=10;
   
   `CLOCK(clk, PER)
   `RESET(rst, 7, 10)
   `SIGNAL(KNN_ENABLE, 1)
   `SIGNAL(KNN_DATA_IN, 32)

   `SIGNAL(x_a, 32)
   `SIGNAL(x_b, 32)
   `SIGNAL(y_a, 32)
   `SIGNAL(y_b, 32)
   
   `SIGNAL_OUT(KNN_DATA_OUT, 32)
   
   `SIGNAL_OUT(d, 32)
   
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
         x_a=i;
         x_b=i*2;
         y_a=i;
         y_b=i*2;
         $display("%d -> x_a: %d , x_b: %d , Dist: %d",i, x_a, x_b, d);
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
    .x_a(x_a),  
    .x_b(x_b),  
    .y_a(y_a),
    .y_b(y_b),
    .d(d)
   );
       

endmodule
