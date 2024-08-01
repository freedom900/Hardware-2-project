module normalization(
	P, exp_z, sticky, guard, mantissa_norm, exp_norm
);

	input logic [47:0] P;
	input logic [9:0] exp_z;
	output logic sticky, guard;
	output logic [22:0] mantissa_norm;
	output logic [9:0] exp_norm;

	always_comb begin 
		if (P[47] == 1) begin
			mantissa_norm = P[46:24] << 1;
			exp_norm = exp_z + 1;
			guard = P[23];
			sticky = |P[22:0];
		end 
		else begin //(P[47] == 0) 
			mantissa_norm = P[45:23];
			exp_norm = exp_z;
			guard = P[22];
			sticky = |P[21:0];
		end
	end
endmodule
