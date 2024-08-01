//This module is given for the exercises
module fp_mult_top (
     clk, rst, rnd, a, b, z, status, ref_result, round_str
);
    import mult::*;
    input logic [31:0] a, b;  // Floating-Point numbers	 
    input logic [2:0] rnd; // Rounding signal
    input string round_str;
    output logic [31:0] z;    // a ± b
    output logic [7:0] status;  // Status Flags 
    output bit [31:0] ref_result;
    input logic clk, rst; 
    
    logic [31:0] a1, b1;  // Floating-Point numbers
    logic [2:0] rnd1; // Rounding signal
    logic [31:0] z1;    // a ± b
    logic [7:0] status1;  // Status Flags 

    fp_mult multiplier(a1,b1,rnd1,z1,status1);
    
    always @(posedge clk)
       if (rst == 1)
          begin 
             a1 <= '0;
             b1 <= '0;
	     rnd1 <= '0;
             z <= '0;
             status <= '0;
	     ref_result <= '0;
          end
       else
          begin
             a1 <= a;
             b1 <= b;
	     rnd1 <= rnd;
             z <= z1;
             status <= status1;
	     ref_result <= multiplication(round_str, a, b);
          end

endmodule