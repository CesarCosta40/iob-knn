`timescale 1ns / 1ps
`include "iob_lib.vh"

module sorter
  #(
    parameter W=32
    )
  (
   `INPUT(rst,1),
   `INPUT(clk,1),
   //`INPUT(en,1),
   `INPUT(DATA_IN,W), 
   `OUTPUT(DATA0_OUT,W),
   `OUTPUT(DATA1_OUT,W),
   `OUTPUT(DATA2_OUT,W),
   `OUTPUT(DATA3_OUT,W)
   );

   
   `SIGNAL(DATA0_OUT_INT, W)
   `SIGNAL(DATA1_OUT_INT, W)
   `SIGNAL(DATA2_OUT_INT, W)
   `SIGNAL(DATA3_OUT_INT, W)
   `SIGNAL(DATA1_IN_INT, W)
   `SIGNAL(DATA2_IN_INT, W)
   `SIGNAL(DATA3_IN_INT, W)
   `SIGNAL(c0, 1)
   `SIGNAL(c1, 1)
   `SIGNAL(c2, 1)
   `SIGNAL(c3, 1)
   

   `SIGNAL2OUT(DATA0_OUT, DATA0_OUT_INT) //connect internal result to output
   `SIGNAL2OUT(DATA1_OUT, DATA1_OUT_INT)
   `SIGNAL2OUT(DATA2_OUT, DATA2_OUT_INT) 
   `SIGNAL2OUT(DATA3_OUT, DATA3_OUT_INT) 
   

   `REG_RE(clk, rst, 32'Hffffffff , c0, DATA0_OUT_INT , DATA_IN)
   `REG_RE(clk, rst, 32'Hffffffff , c1, DATA1_OUT_INT , DATA1_IN_INT)  
   `REG_RE(clk, rst, 32'Hffffffff , c2, DATA2_OUT_INT , DATA2_IN_INT)
   `REG_RE(clk, rst, 32'Hffffffff , c3, DATA3_OUT_INT , DATA3_IN_INT)

   `COMB begin

	if(DATA_IN < DATA0_OUT_INT) begin
		c0=1;
		DATA1_IN_INT = DATA0_OUT_INT;
	end
	else begin
		c0=0;
		DATA1_IN_INT = DATA_IN;
	end

	
	if(DATA_IN < DATA1_OUT_INT) begin
		c1=1;
		DATA2_IN_INT = DATA1_OUT_INT;
	end
	else begin
		c1=0;
		DATA2_IN_INT = DATA_IN;
	end
	
	if(DATA_IN < DATA2_OUT_INT) begin
		c2=1;
		DATA3_IN_INT = DATA2_OUT_INT;
	end
	else begin
		c2=0;
		DATA3_IN_INT = DATA_IN;
	end
		
	if(DATA_IN < DATA3_OUT_INT) c3=1;
	else c3=0;
	
  end

endmodule
