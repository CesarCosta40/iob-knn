`timescale 1ns/1ps
`include "iob_lib.vh"
`include "interconnect.vh"
`include "iob_knn.vh"

module iob_knn
#(
  parameter ADDR_W = `KNN_ADDR_W, //NODOC Address width
  parameter DATA_W = `DATA_W, //NODOC Data word width
  parameter WDATA_W = `KNN_WDATA_W, //NODOC Data word width on writes
  parameter HW_K = `HW_K,
  parameter N_SOLVERS = `N_SOLVERS
)
(
  `include "cpu_nat_s_if.v"
  `include "gen_if.v"
  );

  //BLOCK Register File & Configuration, control and status registers accessible by the sofware
  `include "KNNsw_reg.v"
  `include "KNNsw_reg_gen.v"

  //combined hard/soft reset
  `SIGNAL(rst_int, 1)
  `COMB rst_int = rst | KNN_RESET;

  //write signal
  `SIGNAL(write, 1)
  `COMB write = | wstrb;

  knn #(.HW_K(HW_K),.N_SOLVERS(N_SOLVERS),.DATA_W(DATA_W)) knn0
  (
    .DATA_1(DATA_1),
    .DATA_2(DATA_2),
    .SOLVER_SEL(SOLVER_SEL),
    .rst(rst_int),
    .hard_rst(rst),
    .clk(clk),
    .valid(valid),
    .DONE(DONE),
    .SERIES_ENABLE(SERIES_ENABLE),
    .SEL(SEL),
    .DATA_OUT(DATA_OUT)
  );


  //ready signal
  `SIGNAL(ready_int, 1)
  `REG_AR(clk, rst, 0, ready_int, valid)

  `SIGNAL2OUT(ready, ready_int)

endmodule
