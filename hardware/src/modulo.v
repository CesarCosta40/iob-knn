`timescale 1ns/1ps
`include "iob_lib.vh"

module knn
  #(
    parameter W=32,
    parameter HW_K=10,
    parameter N_SOLVERS=2,
    parameter DATA_W=32 //NODOC Data word width
  )
    (
     input signed [W-1:0] DATA_1,//`INPUT(DATA_1,W),
     input signed [W-1:0] DATA_2,//`INPUT(DATA_2,W),
     `INPUT(SOLVER_SEL,W/2),
     `INPUT(rst,1),
     `INPUT(clk,1),
     `INPUT(valid,1),
     `INPUT(DONE, 1),
     input [15:0] SEL,
     output [W/2-1:0] DATA_OUT
     );


    //`SIGNAL(DATA_X1, 16)
    //`SIGNAL(DATA_Y1, 16)
    `SIGNAL(DATA_X2, 16)
    `SIGNAL(DATA_Y2, 16)

     reg [DATA_W/2-1:0] data_out_solvers [N_SOLVERS-1:0];
     `SIGNAL(data_out_int, DATA_W/2)


     reg signed [DATA_W/2-1:0] DATA_X1 [N_SOLVERS-1:0];
     reg signed [DATA_W/2-1:0] DATA_Y1 [N_SOLVERS-1:0];

     integer j;

     always @(posedge clk, posedge rst) begin
       for(j=0; j < N_SOLVERS; j=j+1) begin
        if (rst) DATA_X1[j] <= 0; else if (SOLVER_SEL==j) DATA_X1[j] <= DATA_1[DATA_W/2-1:0];
      end
     end

     always @(posedge clk, posedge rst) begin
       for(j=0; j < N_SOLVERS; j=j+1) begin
        if (rst) DATA_Y1[j] <= 0; else if (SOLVER_SEL==j) DATA_Y1[j] <= DATA_1[DATA_W-1:DATA_W/2];
      end
     end


   `COMB begin
     /*
     DATA_Y1=DATA_1[31:16];
     DATA_X1=DATA_1[15:0];
     */

     DATA_Y2=DATA_2[31:16];
     DATA_X2=DATA_2[15:0];
    end


    genvar i;
    generate
      for(i = 0; i < N_SOLVERS; i=i+1) begin
        pipeline_sorter #(.HW_K(HW_K)) pipeline_sorter0
        (
          .rst(rst),
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


endmodule
