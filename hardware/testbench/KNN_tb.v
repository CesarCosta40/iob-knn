`timescale 1ns/1ps
`include "iob_lib.vh"
`include "interconnect.vh"

module knn_tb;

  localparam PER=10;

  localparam N_SOLVERS=10;

  `CLOCK(clk, PER)
  `RESET(rst, 7, 10)

  `SIGNAL(DATA_1, 32)
  `SIGNAL(DATA_2, 32)
  `SIGNAL_OUT(DATA_OUT, 16)
  `SIGNAL(ready, 1)
  `SIGNAL(DONE, 1)
  `SIGNAL(SEL, 16)
  `SIGNAL(SOLVER_SEL, 16)
  `SIGNAL(SERIES_ENABLE, 1)
  integer i;
  integer k;
  integer c;
  integer m;
  integer n;

  initial begin
    `ifdef VCD
          $dumpfile("knn.vcd");
          $dumpvars();
    `endif
    DONE = 1;
    SEL = 0;
    SOLVER_SEL = 0;
    DATA_1 = 0;
    DATA_2 = 0;
    ready = 0;
    SERIES_ENABLE=0;

    @(posedge rst);
    @(negedge rst);

    @(posedge clk);
    #5 ready=1;
    #5 ready=0;

    @(posedge clk);

    //ready=0;
    for(c = 0; c < N_SOLVERS; c=c+1) begin
      SOLVER_SEL = c;
      DATA_1 =0;
      SERIES_ENABLE=(c%3!=0);
      @(posedge clk);
    end
    
    @(posedge clk);
    DONE=0;


      for (i=1; i<2000; i=i+1) begin
        if(i%10==0) begin
          DATA_2 = (i<<16)|i;
          #5 ready=0;
        end
        else if(i%10==9)begin
          #5 ready=1;  
        end
         else begin
          ready=0;
        end
        @(posedge clk);
      end

    DONE = 1;

    for(m = 0; m < N_SOLVERS; m=m+1) begin
      SOLVER_SEL = m;
      for (k=0; k<`HW_K; k=k+1) begin
        SEL = k;
        #1 $display("Final REG %d -> DATA_OUT : %d\t", k, DATA_OUT);
        @(posedge clk);
      end
      $display("\n");
    end

    DONE = 0;

    @(posedge clk) #1

    $finish;

  end

  knn #(.HW_K(`HW_K),.N_SOLVERS(N_SOLVERS),.DATA_W(`DATA_W)) knn0
 (
    .rst(rst),
    .hard_rst(rst),
    .clk(clk),
    .valid(ready),
    .DONE(DONE),
    .SEL(SEL),
    .SOLVER_SEL(SOLVER_SEL),
    .SERIES_ENABLE(SERIES_ENABLE),
    .DATA_1(DATA_1),
    .DATA_2(DATA_2),
    .DATA_OUT(DATA_OUT)
  );

endmodule
