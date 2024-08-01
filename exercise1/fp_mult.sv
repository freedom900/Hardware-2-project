module fp_mult (
	a, b, round, z, status
    
);
	import rounding_pkg::*;
    	input logic [31:0] a, b;
    	input logic [2:0] round;
    	output logic [31:0] z;
    	output logic [7:0] status;

    	// Other signals
	logic sign_a, sign_b, sign_z, sticky, guard, inexact, overflow, underflow;
   	logic [7:0] exp_a, exp_b;
	logic [9:0] exp_z, exp_z_no_bias, exp_norm, exp_round;
	logic [22:0] mantissa_norm;
   	logic [23:0] mantissa_a, mantissa_b, mantissa_round;
	logic [24:0] result;
   	logic [47:0] mantissa_mult;
   	logic [7:0] exception_status;
 	logic zero_f, inf_f, nan_f, tiny_f, huge_f, inexact_f;
	logic [31:0] z_calc;

	// 1) Floating point number sign calculation
	always_comb begin
   		sign_a = a[31];
    		sign_b = b[31];
		sign_z = sign_a ^ sign_b;

    		// 2) Exponent addition
    		exp_a = a[30:23];
		exp_b = b[30:23];
    		exp_z = exp_a + exp_b;

		// 3) Exponent subtraction of bias
		exp_z_no_bias = exp_z - 10'd127; 

    		// 4) Mantissa multiplication (including leading ones)
		mantissa_a = {1'b1, a[22:0]};
    		mantissa_b = {1'b1, b[22:0]};
    		mantissa_mult = mantissa_a * mantissa_b;
	end

    	// 5) Truncation and normalization
    	normalization norm_inst (.P(mantissa_mult), .exp_z(exp_z_no_bias), .*);    
 	
    	// 6) Rounding
	always_comb begin
		mantissa_round = {1'b1, mantissa_norm};
	end
   	rounding round_inst (.mantissa(mantissa_round), .calc_sign(sign_z), .*);

   	// 7) Exception handling
	// Check for overflow and underflow
	always_comb begin
        	overflow = (signed'(exp_round) > 255);
        	underflow = (signed'(exp_norm) < 0);
		z_calc = {sign_z, exp_round[7:0], result[22:0]};
    	end
	exception except_inst(.*);

    	// Status update
    	assign status = {2'b00, inexact_f, huge_f, tiny_f, nan_f, inf_f, zero_f};
    
endmodule

