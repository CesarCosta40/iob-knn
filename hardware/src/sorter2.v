`timescale 1ns / 1ps
`include "iob_lib.vh"

module sorter
  #(
    parameter W=32
  )
  (
  `INPUT(rst,1),
  `INPUT(clk,1),
  `INPUT(valid,1),
  `INPUT(DONE, 1),
  input [3:0] SEL,
  input signed [W/2-1:0] DATA_X1,
  input signed [W/2-1:0] DATA_X2,
  input signed [W/2-1:0] DATA_Y1,
  input signed [W/2-1:0] DATA_Y2,
  output [W/4-1:0] DATA_OUT
  );

  //distancia
  `SIGNAL_SIGNED(sub1, W)
  `SIGNAL_SIGNED(sub2, W)
  `SIGNAL(sqr1, W)
  `SIGNAL(sqr2, W)
  `SIGNAL(DIST, W+1)
  //inserção
  reg [W:0] DATA_OUT_INT [0:9];
  reg [W:0] DATA_IN_INT [1:9];
  reg [W/4:0] idx_out_int [0:9];
  reg [W/4:0] idx_cnt_int [1:9];
  reg c [0:9];
  
  integer i;
  integer j;
  integer n;
  integer m;
  
  `SIGNAL(idx_out, W/4)
  `SIGNAL(idx_cnt, W/4)
  //`SIGNAL(valid_cnt, 2)
  `SIGNAL(ready, 1)

  `SIGNAL2OUT(DATA_OUT, idx_out) //connect internal result to output
  

 // `REG_ARE(clk, rst, 0, (valid&(!DONE))|ready, valid_cnt, ready==1? !1: valid_cnt+1)//Ready signal is once every two valids

  //`REG_ARE(clk, rst, 0, !DONE, ready, ready==1? !1: valid_cnt[1:1])
  
  `REG_ARE(clk, rst, 0, !DONE, ready, valid)

  `REG_RE(clk, rst, 32'Hffffffff , ready&c[0]&(!DONE), DATA_OUT_INT[0] , DIST)
  
  always @(posedge clk) begin
  	for(n=1; n<10 ; n=n+1) begin
  		if (rst) DATA_OUT_INT[n] <= 32'Hffffffff; else if (ready&c[n]&(!DONE)) DATA_OUT_INT[n] <= DATA_IN_INT[n];
  	end
  end
  
  `REG_RE(clk, rst, 8'H00 , ready&c[0]&(!DONE), idx_out_int[0] , idx_cnt)
  
  always @(posedge clk) begin
  	for(m=1; m<10 ; m=m+1) begin
  		if (rst) idx_out_int[m] <= 8'H00; else if (ready&c[m]&(!DONE)) idx_out_int[m] <= idx_cnt_int[m];
  	end
  end


  `COUNTER_ARE(clk, rst, ready&(!DONE), idx_cnt)


  `COMB begin
    sub1 = DATA_X1 - DATA_X2;
    sub2 = DATA_Y1 - DATA_Y2;
    sqr1 = sub1 * sub1;
    sqr2 = sub2 * sub2;
    DIST = sqr1 + sqr2;
  end

  `COMB begin
  	
    for(i=0; i<9 ; i=i+1) begin
  	
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
 	
    if(DIST < DATA_OUT_INT[9]) c[9]=1;
    else c[9]=0;
  	
  end

  `COMB begin
  
    for(j=0; j<10 ; j=j+1) if(SEL==j) idx_out = idx_out_int[j];
  	
  end

endmodule
