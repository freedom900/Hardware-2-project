package rounding_pkg;
	typedef enum logic[2:0]{
		IEEE_near = 3'b000,
		IEEE_zero = 3'b001,
		IEEE_pinf = 3'b010,
		IEEE_ninf = 3'b011,
		near_up = 3'b100,
		away_zero = 3'b101
	} round_t;

	function automatic string round_t_to_string (round_t round_num);
		string round_str;
		case(round_num)
			3'b000: round_str = "IEEE_near";
			3'b001: round_str = "IEEE_zero";
			3'b010: round_str = "IEEE_pinf";
			3'b011: round_str = "IEEE_ninf";
			3'b100: round_str = "near_up";
			3'b101: round_str = "away_zero";
			default: round_str = "IEEE_near";
		endcase
        	return round_str;
	endfunction
endpackage

