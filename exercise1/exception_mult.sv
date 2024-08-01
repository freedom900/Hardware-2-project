module exception(
	a, b, z_calc, overflow, underflow, inexact, round, z, zero_f, inf_f, nan_f, tiny_f, huge_f, inexact_f
);
	import rounding_pkg::*;
	input logic [31:0] a, b, z_calc;
	input logic overflow, underflow, inexact;
	input logic [2:0] round;
	output logic [31:0] z;
	output logic zero_f, inf_f, nan_f, tiny_f, huge_f, inexact_f;

	typedef enum logic [2:0] {
		ZERO, INF, NORM, MIN_NORM, MAX_NORM
	} interp_t;

	// Denormals -> 0, NaNs -> inf
	function automatic interp_t num_interp(input logic [31:0] signal);
		logic [7:0] exp;
		exp = signal[30:23];
		if (exp == 8'b0) begin
			return ZERO; // Also counts denormals
		end else if (exp == 8'b11111111) begin
			return INF; // Also counts NaNs
		end else begin
			return NORM;
		end	endfunction

	function automatic logic[30:0] z_num(input interp_t interp);
		case (interp)
			ZERO: return 31'b0;
			INF: return {8'b11111111, 23'b0};	
			MIN_NORM: return {8'b00000001, 23'b0};
			MAX_NORM: return {8'b11111110, 23'b11111111111111111111111};
		endcase
	endfunction

	always_comb begin
		automatic interp_t interp_a = num_interp(a);
		automatic interp_t interp_b = num_interp(b);

		zero_f = 0;
		inf_f = 0;
		nan_f = 0;
		tiny_f = 0;
		huge_f = 0;
		inexact_f = inexact;

		case(interp_a)
			ZERO: begin
				case(interp_b)
					ZERO, NORM: begin 
						z = {z_calc[31], z_num(ZERO)};
						zero_f = 1;
					end
					INF: begin 
						z = {1'b0, z_num(INF)};
						nan_f = 1;
					end
				endcase
			end
			INF: begin 
				case(interp_b)
					ZERO: begin 
						z = {1'b0, z_num(INF)};
						nan_f = 1;
					end
					NORM, INF: begin 
						z = {z_calc[31], z_num(INF)};
						inf_f = 1;
					end
				endcase
			end
			NORM: begin 
				case(interp_b)
					ZERO: begin
						z = {z_calc[31], z_num(ZERO)};
						zero_f = 1;
					end
					INF: begin
						z = {z_calc[31], z_num(INF)};
						inf_f = 1;
					end
					NORM: begin
						if (overflow) begin
							huge_f = 1;
							if (z_calc[31] == 0) begin //positive
								if (round == IEEE_pinf || round == away_zero || round == near_up || round == IEEE_near) begin
									z = {z_calc[31], z_num(INF)};
									inf_f = 1;
								end else if (round == IEEE_ninf || round == IEEE_zero) begin
									z = {z_calc[31], z_num(MAX_NORM)};
								end
							end else begin // z_calc[31] == 1 negative
								if (round == IEEE_pinf || round == IEEE_zero) begin
									z = {z_calc[31], z_num(MAX_NORM)};
								end else if (round == IEEE_ninf || round == away_zero || round == near_up || round == IEEE_near) begin
									z = {z_calc[31], z_num(INF)};
									inf_f = 1;
								end
							end
						end else if (underflow) begin
							tiny_f = 1;
							if (z_calc[31] == 0) begin //positive
								if (round == IEEE_pinf || round == away_zero) begin
									z = {z_calc[31], z_num(MIN_NORM)};
								end else if (round == IEEE_ninf || round == IEEE_zero || round == IEEE_near || round == near_up) begin
									z = {z_calc[31], z_num(ZERO)};
									zero_f = 1;
								end
							end else begin // z_calc[31] == 1 negative
								if (round == IEEE_pinf || round == IEEE_zero || round == IEEE_near || round == near_up) begin
									z = {z_calc[31], z_num(ZERO)};
									zero_f = 1;
								end else if (round == IEEE_ninf || round == away_zero) begin
									z = {z_calc[31], z_num(MIN_NORM)};
								end 
							end
						end else begin // Neither overflow nor underflow
							z = z_calc;
							inexact_f = inexact;
						end
					end
				endcase
			end
		endcase
	end
	
endmodule
