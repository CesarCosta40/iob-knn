`timescale 1ns/1ps
`include "iob_lib.vh"
`include "interconnect.vh"

module knn_tb;

  localparam PER=10;

  `CLOCK(clk, PER)
  `RESET(rst, 7, 10)

  `SIGNAL_SIGNED(DATA_X1, 16)
  `SIGNAL_SIGNED(DATA_Y1, 16)
  `SIGNAL_SIGNED(DATA_X2, 16)
  `SIGNAL_SIGNED(DATA_Y2, 16)
  `SIGNAL_OUT(DATA_OUT, 8)
  `SIGNAL(ready, 1)
  `SIGNAL(DONE, 1)
  `SIGNAL(SEL, 2)

  integer i;
  integer k;

  initial begin
    `ifdef VCD
          $dumpfile("knn.vcd");
          $dumpvars();
    `endif
    DONE = 0;
    SEL = 0;
    ready = 0;
    DATA_X1 = 0;
    DATA_Y1 = 0;
    @(posedge rst);
    @(negedge rst);

    for (i=1; i<100; i=i+1) begin
      if(i%5==0)
        ready=1;
      else
        ready=0;
      if (ready==1)begin
        DATA_X2 = $random%20;
        DATA_Y2 = $random%20;
      end
      @(posedge clk);
    end
    DONE = 1;
    for (k=0; k<4; k=k+1) begin
      SEL = k;
      #1 $display("Final REG %d -> DATA_OUT : %d\t", k, DATA_OUT);
      @(posedge clk);
    end
    $display("\n");

    @(posedge clk) #100

    $finish;
  end

  sorter sorter0
  (
    .rst(rst),
    .clk(clk),
    .ready(ready),
    .DONE(DONE),
    .SEL(SEL),
    .DATA_X1(DATA_X1),
    .DATA_Y1(DATA_Y1),
    .DATA_X2(DATA_X2),
    .DATA_Y2(DATA_Y2),
    .DATA_OUT(DATA_OUT)
  );


endmodule
