`timescale 1ns / 1ps
`include "iob_lib.vh"

module sorter
  #(
    parameter W=32,
    parameter HW_K=10
  )
  (
  `INPUT(rst,1),
  `INPUT(clk,1),
  `INPUT(valid,1),
  `INPUT(DONE, 1),
  input [15:0] SEL,
  input signed [W:0] DIST,
  input signed [W:0] DIST_EXT_IN,
  output signed [W:0] DIST_EXT_OUT,
  input [W/2-1:0] idx_cnt_ext_in,
  output [W/2-1:0] idx_cnt_ext_out,
  input [1:0] series_enable,
  input [1:0] cn_in,
  output [1:0] cn_out,
  output [W/2-1:0] DATA_OUT
);

  //inserção
  reg [W:0] DATA_OUT_INT [0:HW_K-1];
  reg [W:0] DATA_IN_INT [0:HW_K-1];
  reg [W/2-1:0] idx_out_int [0:HW_K-1];
  reg [W/2-1:0] idx_cnt_int [0:HW_K-1];
  reg c [0:HW_K-1];

  integer i;
  integer j;
  integer n;
  integer m;

  `SIGNAL(idx_out, W/2)
  `SIGNAL(idx_cnt, W/2)
  `SIGNAL(ready, 1)

  `SIGNAL2OUT(DATA_OUT, idx_out) //connect internal result to output


  `REG_ARE(clk, rst, 0, !DONE, ready, valid)

  //`REG_RE(clk, rst, 32'Hffffffff , ready&c[0]&(!DONE), DATA_OUT_INT[0] , DIST)

  always @(posedge clk) begin
  	for(n=0; n<HW_K ; n=n+1) begin
  		if (rst) DATA_OUT_INT[n] <= 32'Hffffffff; else if (ready&c[n]&(!DONE)) DATA_OUT_INT[n] <= DATA_IN_INT[n];
  	end
  end

  //`REG_RE(clk, rst, 8'H00 , ready&c[0]&(!DONE), idx_out_int[0] , idx_cnt)

  always @(posedge clk) begin
  	for(m=0; m<HW_K; m=m+1) begin
  		if (rst) idx_out_int[m] <= 8'H00; else if (ready&c[m]&(!DONE)) idx_out_int[m] <= idx_cnt_int[m];
  	end
  end


  `COUNTER_ARE(clk, rst, ready&(!DONE), idx_cnt)


  `COMB begin

    if(series_enable==0||(series_enable==1&&cn_in==0)) begin
      DATA_IN_INT[0]=DIST;
      idx_cnt_int[0]=idx_cnt;
    end 
    else begin
        DATA_IN_INT[0]=DIST_EXT_IN;
        idx_cnt_int[0]=idx_cnt_ext_in;
    end

    for(i=0; i<HW_K-1; i=i+1) begin

     	if(DIST < DATA_OUT_INT[i]) begin
  	  	c[i]=1;
  	  	DATA_IN_INT[i+1] = DATA_OUT_INT[i];
  	  	idx_cnt_int[i+1] = idx_out_int[i];
  	  end
  	  else begin
  	  	c[i]=0;
  	  	DATA_IN_INT[i+1] = DIST;
  	  	idx_cnt_int[i+1] = idx_cnt;
  	  end

    end

    if(DIST < DATA_OUT_INT[HW_K-1]) c[HW_K-1]=1;
    else c[HW_K-1]=0;

  end

  `SIGNAL2OUT(DIST_EXT_OUT, DATA_OUT_INT[HW_K-1])
  `SIGNAL2OUT(idx_cnt_ext_out, idx_out_int[HW_K-1])
  `SIGNAL2OUT(cn_out, c[HW_K-1])

  `COMB begin

    for(j=0; j<HW_K ; j=j+1) if(SEL==j) idx_out = idx_out_int[j];

  end

endmodule
