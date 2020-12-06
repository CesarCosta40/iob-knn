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
  `SIGNAL(SEL, 4)

  `SIGNAL(y, 1)

  integer j;
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

    for (j=0; j<2; j=j+1) begin
      for (i=1; i<100; i=i+1) begin
        if(i%3==0)
          ready=1;
        else
          ready=0;
        if (ready==1)begin
          if(y==0) begin
            DATA_X2 = i;
            y=1; end
            else begin
            DATA_Y2 = i;
            y=0;
          end
        end
        @(posedge clk);
      end
      DONE = 1;
      for (k=0; k<10; k=k+1) begin
        SEL = k;
        #1 $display("Final REG %d -> DATA_OUT : %d\t", k, DATA_OUT);
        @(posedge clk);
      end
      $display("\n");
      DONE = 0;

      begin
        #1 rst=1;
        #10 rst=0;
      end

    end
    @(posedge clk) #1

    $finish;

  end

  sorter sorter0
  (
    .rst(rst),
    .clk(clk),
    .valid(ready),
    .DONE(DONE),
    .SEL(SEL),
    .DATA_X1(DATA_X1),
    .DATA_Y1(DATA_Y1),
    .DATA_X2(DATA_X2),
    .DATA_Y2(DATA_Y2),
    .DATA_OUT(DATA_OUT)
  );
endmodule
