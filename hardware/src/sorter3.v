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
  output [W/2-1:0] DATA_OUT
  );

  //inserção
  reg [W:0] DATA_OUT_INT [0:HW_K-1];
  reg [W:0] DATA_IN_INT [1:HW_K-1];
  reg [W/2-1:0] idx_out_int [0:HW_K-1];
  reg [W/2-1:0] idx_cnt_int [1:HW_K-1];
  reg c [0:HW_K-1];

  integer i;
  integer j;
  integer n;
  integer m;

  `SIGNAL(idx_out, W/2)
  `SIGNAL(idx_cnt, W/2)
  //`SIGNAL(valid_cnt, 2)
  `SIGNAL(ready, 1)

  `SIGNAL2OUT(DATA_OUT, idx_out) //connect internal result to output


 // `REG_ARE(clk, rst, 0, (valid&(!DONE))|ready, valid_cnt, ready==1? !1: valid_cnt+1)//Ready signal is once every two valids

  //`REG_ARE(clk, rst, 0, !DONE, ready, ready==1? !1: valid_cnt[1:1])

  `REG_ARE(clk, rst, 0, !DONE, ready, valid)

  `REG_RE(clk, rst, 32'Hffffffff , ready&c[0]&(!DONE), DATA_OUT_INT[0] , DIST)

  always @(posedge clk) begin
  	for(n=1; n<HW_K ; n=n+1) begin
  		if (rst) DATA_OUT_INT[n] <= 32'Hffffffff; else if (ready&c[n]&(!DONE)) DATA_OUT_INT[n] <= DATA_IN_INT[n];
  	end
  end

  `REG_RE(clk, rst, 8'H00 , ready&c[0]&(!DONE), idx_out_int[0] , idx_cnt)

  always @(posedge clk) begin
  	for(m=1; m<HW_K; m=m+1) begin
  		if (rst) idx_out_int[m] <= 8'H00; else if (ready&c[m]&(!DONE)) idx_out_int[m] <= idx_cnt_int[m];
  	end
  end


  `COUNTER_ARE(clk, rst, ready&(!DONE), idx_cnt)


  `COMB begin

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

  `COMB begin

    for(j=0; j<HW_K ; j=j+1) if(SEL==j) idx_out = idx_out_int[j];

  end

endmodule
