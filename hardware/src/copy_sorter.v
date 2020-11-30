`timescale 1ns / 1ps
`include "iob_lib.vh"

module sorter
  #(
    parameter W=32
    )
  (
   `INPUT(rst,1),
   `INPUT(clk,1),
   `INPUT(ready,1),
   `INPUT(done, 1),
   `INPUT(DATA_IN,W), 
   `OUTPUT(DATA0_OUT,W/4),
   `OUTPUT(DATA1_OUT,W/4),
   `OUTPUT(DATA2_OUT,W/4),
   `OUTPUT(DATA3_OUT,W/4)
   );

   
   `SIGNAL(DATA0_OUT_INT, W)
   `SIGNAL(DATA1_OUT_INT, W)
   `SIGNAL(DATA2_OUT_INT, W)
   `SIGNAL(DATA3_OUT_INT, W)
   `SIGNAL(DATA1_IN_INT, W)
   `SIGNAL(DATA2_IN_INT, W)
   `SIGNAL(DATA3_IN_INT, W)
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
   

   `SIGNAL2OUT(DATA0_OUT, idx0_out) //connect internal result to output
   `SIGNAL2OUT(DATA1_OUT, idx1_out)
   `SIGNAL2OUT(DATA2_OUT, idx2_out) 
   `SIGNAL2OUT(DATA3_OUT, idx3_out) 
   

   `REG_RE(clk, rst, 32'Hffffffff , ready&c0, DATA0_OUT_INT , DATA_IN)
   `REG_RE(clk, rst, 32'Hffffffff , ready&c1, DATA1_OUT_INT , DATA1_IN_INT)  
   `REG_RE(clk, rst, 32'Hffffffff , ready&c2, DATA2_OUT_INT , DATA2_IN_INT)
   `REG_RE(clk, rst, 32'Hffffffff , ready&c3, DATA3_OUT_INT , DATA3_IN_INT)
   
   `REG_RE(clk, rst, 8'H00 , ready&c0&(!done), idx0_out , idx_cnt)
   `REG_RE(clk, rst, 8'H00 , ready&c1&(!done), idx1_out , idx1_cnt_int)  
   `REG_RE(clk, rst, 8'H00 , ready&c2&(!done), idx2_out , idx2_cnt_int)
   `REG_RE(clk, rst, 8'H00 , ready&c3&(!done), idx3_out , idx3_cnt_int)
   
   `COUNTER_ARE(clk, rst, ready, idx_cnt)
   
   `COMB begin

	if(DATA_IN < DATA0_OUT_INT) begin
		c0=1;
		DATA1_IN_INT = DATA0_OUT_INT;
		idx1_cnt_int = idx0_out;
	end
	else begin
		c0=0;
		DATA1_IN_INT = DATA_IN;
		idx1_cnt_int = idx_cnt;
	end

	
	if(DATA_IN < DATA1_OUT_INT) begin
		c1=1;
		DATA2_IN_INT = DATA1_OUT_INT;
		idx2_cnt_int = idx1_out;
	end
	else begin
		c1=0;
		DATA2_IN_INT = DATA_IN;
		idx2_cnt_int = idx_cnt;
	end
	
	if(DATA_IN < DATA2_OUT_INT) begin
		c2=1;
		DATA3_IN_INT = DATA2_OUT_INT;
		idx3_cnt_int = idx2_out;
	end
	else begin
		c2=0;
		DATA3_IN_INT = DATA_IN;
		idx3_cnt_int = idx_cnt;
	end
		
	if(DATA_IN < DATA3_OUT_INT) c3=1;
	else c3=0;
	
  end

endmodule
