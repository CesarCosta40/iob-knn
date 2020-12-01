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
  input [1:0] SEL,
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
  `SIGNAL(DIST, W)
  //inserção
  `SIGNAL(DATA0_OUT_INT, W)
  `SIGNAL(DATA1_OUT_INT, W)
  `SIGNAL(DATA2_OUT_INT, W)
  `SIGNAL(DATA3_OUT_INT, W)
  `SIGNAL(DATA1_IN_INT, W)
  `SIGNAL(DATA2_IN_INT, W)
  `SIGNAL(DATA3_IN_INT, W)
  `SIGNAL(idx_out, W/4)
  `SIGNAL(idx0_out, W/4)
  `SIGNAL(idx1_out, W/4)
  `SIGNAL(idx2_out, W/4)
  `SIGNAL(idx3_out, W/4)
  `SIGNAL(c0, 1)
  `SIGNAL(c1, 1)
  `SIGNAL(c2, 1)
  `SIGNAL(c3, 1)
  `SIGNAL(idx_cnt, W/4)
  `SIGNAL(idx1_cnt_int, W/4)
  `SIGNAL(idx2_cnt_int, W/4)
  `SIGNAL(idx3_cnt_int, W/4)
  `SIGNAL(valid_cnt, 2)
  `SIGNAL(ready, 1)

  `SIGNAL2OUT(DATA_OUT, idx_out) //connect internal result to output


  `REG_ARE(clk, rst, 0, (valid&(!DONE))|ready, valid_cnt, ready==1? !1: valid_cnt+1)//Ready signal is once every two valids

  `REG_ARE(clk, rst, 0, !DONE, ready, ready==1? !1: valid_cnt[1:1])

  `REG_RE(clk, rst, 32'Hffffffff , ready&c0&(!DONE), DATA0_OUT_INT , DIST)
  `REG_RE(clk, rst, 32'Hffffffff , ready&c1&(!DONE), DATA1_OUT_INT , DATA1_IN_INT)
  `REG_RE(clk, rst, 32'Hffffffff , ready&c2&(!DONE), DATA2_OUT_INT , DATA2_IN_INT)
  `REG_RE(clk, rst, 32'Hffffffff , ready&c3&(!DONE), DATA3_OUT_INT , DATA3_IN_INT)

  `REG_RE(clk, rst, 8'H00 , ready&c0&(!DONE), idx0_out , idx_cnt)
  `REG_RE(clk, rst, 8'H00 , ready&c1&(!DONE), idx1_out , idx1_cnt_int)
  `REG_RE(clk, rst, 8'H00 , ready&c2&(!DONE), idx2_out , idx2_cnt_int)
  `REG_RE(clk, rst, 8'H00 , ready&c3&(!DONE), idx3_out , idx3_cnt_int)

  `COUNTER_ARE(clk, rst, ready&(!DONE), idx_cnt)


  `COMB begin
    sub1 = DATA_X1 - DATA_X2;
    sub2 = DATA_Y1 - DATA_Y2;
    sqr1 = sub1 * sub1;
    sqr2 = sub2 * sub2;
    DIST = sqr1 + sqr2;

  	if(DIST < DATA0_OUT_INT) begin
  		c0=1;
  		DATA1_IN_INT = DATA0_OUT_INT;
  		idx1_cnt_int = idx0_out;
  	end
  	else begin
  		c0=0;
  		DATA1_IN_INT = DIST;
  		idx1_cnt_int = idx_cnt;
  	end
  	if(DIST < DATA1_OUT_INT) begin
  		c1=1;
  		DATA2_IN_INT = DATA1_OUT_INT;
  		idx2_cnt_int = idx1_out;
  	end
  	else begin
  		c1=0;
  		DATA2_IN_INT = DIST;
  		idx2_cnt_int = idx_cnt;
  	end
  	if(DIST < DATA2_OUT_INT) begin
  		c2=1;
  		DATA3_IN_INT = DATA2_OUT_INT;
  		idx3_cnt_int = idx2_out;
  	end
  	else begin
  		c2=0;
  		DATA3_IN_INT = DIST;
  		idx3_cnt_int = idx_cnt;
  	end
  	if(DIST < DATA3_OUT_INT) c3=1;
  	else c3=0;
  end

  `COMB begin
    if(SEL==0) idx_out = idx0_out;
    if(SEL==1) idx_out = idx1_out;
    if(SEL==2) idx_out = idx2_out;
    if(SEL==3) idx_out = idx3_out;
  end

endmodule
