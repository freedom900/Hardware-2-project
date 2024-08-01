module rounding(
	mantissa, exp_norm, guard, sticky, calc_sign, round, result, inexact, exp_round
);
	import rounding_pkg::*;
	input logic [23:0] mantissa;
	input logic [9:0] exp_norm;
	input logic guard, sticky, calc_sign;
	input logic [2:0] round;
	output logic [24:0] result;
	output logic inexact;
	output logic [9:0] exp_round;

	logic round_up;

	always_comb begin
		result = 0;
		if (guard == 0 && sticky == 0) begin
			inexact = 0;
		end else begin
			inexact = 1; 
		end

		case (round)
			 IEEE_near: begin
            			if (guard == 1 && (sticky == 1 || mantissa[0] == 1))
               				round_up = 1;
            			else
                			round_up = 0;
        		end
			IEEE_zero: round_up = 0;
			IEEE_pinf: round_up = (~calc_sign && inexact);
			IEEE_ninf: round_up = (calc_sign && inexact);
			near_up: round_up = guard;
			away_zero: round_up = inexact;
			default: begin
            			if (guard == 1 && (sticky == 1 || mantissa[0] == 1))
               				round_up = 1;
            			else
                			round_up = 0;
        		end
		endcase

		if(round_up) begin
			result = mantissa + 1'b1;
		end else begin
			result = mantissa;
		end

		if (result[24] == 1) begin
			result = result >> 1;
			exp_round = exp_norm + 1;
		end else begin
			result = result;
			exp_round = exp_norm;
		end
	end
endmodule