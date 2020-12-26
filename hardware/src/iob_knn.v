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

   //`SIGNAL(DATA_X1, 16)
   //`SIGNAL(DATA_Y1, 16)
   
   reg signed [DATA_W/2-1:0] DATA_X1 [N_SOLVERS-1:0];
   reg signed [DATA_W/2-1:0] DATA_Y1 [N_SOLVERS-1:0];
   
   integer j;

   always @(posedge clk, posedge rst_int) begin
     for(j=0; j < N_SOLVERS; j=j+1) begin
      if (rst_int) DATA_X1[j] <= 0; else if (SOLVER_SEL==j) DATA_X1[j] <= DATA_1[DATA_W/2-1:0];
    end
   end

   always @(posedge clk, posedge rst_int) begin
     for(j=0; j < N_SOLVERS; j=j+1) begin
      if (rst_int) DATA_Y1[j] <= 0; else if (SOLVER_SEL==j) DATA_Y1[j] <= DATA_1[DATA_W-1:DATA_W/2];
    end
   end


   `SIGNAL(DATA_X2, 16)
   `SIGNAL(DATA_Y2, 16)
  
    reg [DATA_W/4-1:0] data_out_solvers [N_SOLVERS-1:0];
    `SIGNAL(data_out_int, 8)


   `COMB begin

    /*
    DATA_Y1=DATA_1[31:16];
    DATA_X1=DATA_1[15:0];
    */

    DATA_Y2=DATA_2[31:16];
    DATA_X2=DATA_2[15:0];
   end


   //
   //BLOCK 64-bit time counter & Free-running 64-bit counter with enable and soft reset capabilities
   //
/*   
   pipeline_sorter #(.HW_K(HW_K)) pipeline_sorter0 
   (
     .rst(rst_int),
     .clk(clk),
     .valid(valid),
     .DONE(DONE),
     .SEL(SEL),
     .DATA_OUT(DATA_OUT),
    .DATA_X1(DATA_X1),
    .DATA_X2(DATA_X2),
    .DATA_Y1(DATA_Y1),
    .DATA_Y2(DATA_Y2)
   );
*/   

  genvar i;
  generate 
    for(i = 0; i < N_SOLVERS; i=i+1) begin
      pipeline_sorter #(.HW_K(HW_K)) pipeline_sorter0
      (
        .rst(rst_int),
        .clk(clk),
        .valid(valid),
        .DONE(DONE),
        .SEL(SEL),
        .DATA_OUT(data_out_solvers[i]),
        .DATA_X1(DATA_X1[i]),
        .DATA_X2(DATA_X2),
        .DATA_Y1(DATA_Y1[i]),
        .DATA_Y2(DATA_Y2)
      );
    end
  endgenerate


   `COMB data_out_int=data_out_solvers[SOLVER_SEL];
    `SIGNAL2OUT(DATA_OUT, data_out_int)

   //ready signal
   `SIGNAL(ready_int, 1)
   `REG_AR(clk, rst, 0, ready_int, valid)

   `SIGNAL2OUT(ready, ready_int)

   //rdata signal
   //`COMB begin
   //end

endmodule
