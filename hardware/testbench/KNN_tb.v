`timescale 1ns/1ps
`include "iob_lib.vh"
`include "interconnect.vh"

module knn_tb;

  localparam PER=10;

  `CLOCK(clk, PER)
  `RESET(rst, 7, 10)

  `SIGNAL(DATA_1, 32)
  `SIGNAL(DATA_2, 32)
  `SIGNAL_OUT(DATA_OUT, 16)
  `SIGNAL(ready, 1)
  `SIGNAL(DONE, 1)
  `SIGNAL(SEL, 16)
  `SIGNAL(SOLVER_SEL, 16)


  integer j;
  integer i;
  integer k;
  integer c;
  integer n_solvers;

  initial begin
    `ifdef VCD
          $dumpfile("knn.vcd");
          $dumpvars();
    `endif
    DONE = 1;
    SEL = 0;
    SOLVER_SEL = 0;
    DATA_1 = 0;
    ready = 0;
    n_solvers = 10;

    @(posedge rst);
    @(negedge rst);

    @(posedge clk);
    #5 ready=1;
    #5 DONE=0;
    #5 ready=0;

    @(posedge clk);

    //ready=0;
    DONE = 1;
    for(int c = 0; c < n_solvers; c++) begin
      SOLVER_SEL = c;
      DATA_1 = $random%31;
    end
    DONE = 0;


    for(int c = 0; c < n_solvers; c++) begin
      SOLVER_SEL = c;
      for (j=0; j<2; j=j+1) begin
        for (i=1; i<100; i=i+1) begin
          if(i%3==0)
            ready=1;
          else
            ready=0;
          if (ready==1)begin
              DATA_2 = i;
            end
          @(posedge clk);
        end
    end

    DONE = 1;
    for(int c = 0; c < n_solvers; c++) begin
      SOLVER_SEL = c;
      for (k=0; k<10; k=k+1) begin
        SEL = k;
        #1 $display("Final REG %d -> DATA_OUT : %d\t", k, DATA_OUT);
        @(posedge clk);
      end
      $display("\n");

      begin
        #1 rst=1;
        #10 rst=0;
      end
    end
    DONE = 0;

    end
    @(posedge clk) #1

    $finish;

  end

  knn #(.HW_K(`HW_K),.N_SOLVERS(`N_SOLVERS),.DATA_W(`DATA_W)) knn0
 (
    .rst(rst),
    .clk(clk),
    .valid(ready),
    .DONE(DONE),
    .SEL(SEL),
    .SOLVER_SEL(SOLVER_SEL),
    .DATA_1(DATA_1),
    .DATA_2(DATA_2),
    .DATA_OUT(DATA_OUT)
  );

endmodule
