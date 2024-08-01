`timescale 1ns/1ps
module tb_main_multiplier;

    	import rounding_pkg::*;
    	import mult::*;
    	logic [31:0] a, b;
    	string round_str;
    	round_t round_a;
    	logic [2:0] rnd;
    	logic [31:0] z;
    	logic [7:0] status;
    	logic rst;
	logic [31:0] corner_cases[11:0];
	bit [31:0] ref_result;

    	parameter CLOCK_PERIOD = 15ns;
	
	bind fp_mult_top test_status_bits u1(clk, status);
	bind fp_mult_top test_status_z_combinations u2(clk, status, a, b, z);

	// Clock generation and variable initialization (rst)
    	logic clk;
    	initial begin
        	clk = 0;
        	rst = 1;
        	#30 rst = 0;
    	end

    	always #(CLOCK_PERIOD/2) clk = ~clk;

	fp_mult_top uut (
        	.clk(clk),
        	.rst(rst),
        	.a(a),
        	.b(b),
        	.rnd(rnd),
        	.z(z),
        	.status(status),
		.ref_result(ref_result),
		.round_str(round_str)
    	);
	always@(posedge clk)
		$display($stime,,,"clk=%b",clk);
    	
    	// Initialize corner cases
	initial begin
    		corner_cases[0] = 32'b01111111100000000000000000000001; // Signaling Positive NaN
    		corner_cases[1] = 32'b11111111100000000000000000000001; // Signaling Negative NaN
    		corner_cases[2] = 32'b01111111100000000000000000000000; // Positive Infinity
    		corner_cases[3] = 32'b11111111100000000000000000000000; // Negative Infinity
    		corner_cases[4] = 32'b01000000101000000000000000000000; // Positive Normal (e.g., 5.0)
    		corner_cases[5] = 32'b11000000101000000000000000000000; // Negative Normal (e.g., -5.0)
    		corner_cases[6] = 32'b00000000000000000000000000000001; // Positive Denormal
    		corner_cases[7] = 32'b10000000000000000000000000000001; // Negative Denormal
    		corner_cases[8] = 32'b00000000000000000000000000000000; // Positive Zero
    		corner_cases[9] = 32'b10000000000000000000000000000000; // Negative Zero
		corner_cases[10] = 32'b01111111110000000000000000000001; // Quiet Positive NaN		
		corner_cases[11] = 32'b11111111110000000000000000000001; // Quiet Negative NaN
 	end

  	// Function to match binary representation to string
  	function string match_case(logic [31:0] value);
    		case (value)
      			32'b01111111100000000000000000000001: return "sig_pos_nan";
      			32'b11111111100000000000000000000001: return "sig_neg_nan";
      			32'b01111111100000000000000000000000: return "pos_inf";
      			32'b11111111100000000000000000000000: return "neg_inf";
      			32'b01000000101000000000000000000000: return "pos_normal";
      			32'b11000000101000000000000000000000: return "neg_normal";
      			32'b00000000000000000000000000000001: return "pos_denormal";
      			32'b10000000000000000000000000000001: return "neg_denormal";
      			32'b00000000000000000000000000000000: return "pos_zero";
      			32'b10000000000000000000000000000000: return "neg_zero";
			32'b01111111110000000000000000000001: return "quiet_pos_nan";
			32'b11111111110000000000000000000001: return "quiet_neg_nan";
      			default: return "unknown";
    		endcase
  	endfunction

	initial begin
        // Random numbers test
		wait(rst == 0);
        	$display("Testing with random numbers");
        	for (int i = 0; i < 100; i = i + 1) begin
            		a = $urandom();
            		b = $urandom();
            		for (int j = 0; j < 6; j = j + 1) begin
				rnd = j;
                		round_a = round_t'(j);
                		round_str = round_t_to_string(round_a);
                		@(posedge clk);
				@(posedge clk);
				#1; // Wait to correctly update the z result
                		if (z !== ref_result) begin
                    			$display("Error: a=%b, b=%b, round=%s, expected=%b, got=%b, status = %b", a, b, round_str, ref_result, z, status);
                		end else begin
                    			$display("Success: a=%b, b=%b, round=%s, result=%b, status = %b", a, b, round_str, z, status);
                		end
				
            		end
        	end
    	// Test corner cases
        	$display("Testing with corner cases");
        	for (int i = 0; i < 12; i++) begin
            		for (int j = 0; j < 12; j++) begin
                		a = corner_cases[i];
                		b = corner_cases[j];
                		for (int k = 0; k < 6; k++) begin
					rnd = k;
                    			round_a = round_t'(k);
                    			round_str = round_t_to_string(round_a);
					@(posedge clk);
					@(posedge clk);
					#1; // Wait to correctly update the z result
                    			if (z !== ref_result) begin
                        			$display("Error: a=%s, b=%s, round=%s, expected=%b, got=%b, status = %b", match_case(a), match_case(b), round_str, ref_result, z, status);
                    			end else begin
                        			$display("Success: a=%s, b=%s, round=%s, result=%b, status = %b", match_case(a), match_case(b), round_str, z, status);
                    			end
                		end
            		end
        	end
    	end
	initial begin
        	#44000;
	       	$finish;
    	end
endmodule

