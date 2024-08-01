module test_status_z_combinations(
	clk, status, a, b, z
);

    	input logic clk;
    	input logic [7:0] status;
    	input logic [31:0] a;
    	input logic [31:0] b;
    	input logic [31:0] z;

	property zero_exp;
    		@(posedge clk)@(posedge clk) status[0] |-> (z[30:23] == 8'b0);
  	endproperty

	property inf_exp;
    		@(posedge clk)@(posedge clk) status[1] |-> (z[30:23] == 8'b11111111);
  	endproperty

	property nan_exp; //(checks the previous 4 cycles since in my testbench code I update the values every 2 clocks)
    		@(posedge clk)@(posedge clk) status[2] |-> (($past(a[30:23],4) == 8'b0 && $past(b[30:23],4) == 8'b11111111) || ($past(a[30:23],4) == 8'b11111111 && $past(b[30:23],4) == 8'b0));
  	endproperty

	property tiny_exp;
    		@(posedge clk)@(posedge clk) status[3] |-> (z[30:23] == 8'b0 || (z[30:23] == 8'b00000001 && z[22:0] == 23'b0));
  	endproperty

	property huge_exp;
    		@(posedge clk)@(posedge clk) status[4] |-> (z[30:23] == 8'b11111111 || (z[30:23] == 8'b11111110 && z[22:0] == 23'b11111111111111111111111));
  	endproperty

	assert property (zero_exp) else $display($stime,,,"FAIL: Property for zero's exponent failed.");
	assert property (inf_exp) else $display($stime,,,"FAIL: Property for inf's exponent failed.");
	assert property (nan_exp) else $display($stime,,,"FAIL: Property for nan's exponent failed.");
	assert property (tiny_exp) else $display($stime,,,"FAIL: Property for tiny's exponent or mantissa failed.");
	assert property (huge_exp) else $display($stime,,,"FAIL: Property for huge's exponent or mantissa failed.");

endmodule
