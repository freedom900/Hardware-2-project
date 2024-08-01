module test_status_bits(
	clk, status

);
	input logic clk;
	input logic[7:0] status;

	assert property (@(posedge clk) !(status[0] && status[1]))
        else $display("FAIL: Zero and Infinity asserted together");

    	assert property (@(posedge clk) !(status[0] && status[2]))
        else $display("FAIL: Zero and NaN asserted together");

    	assert property (@(posedge clk) !(status[0] && status[3]))
        else $display("FAIL: Zero and Tiny asserted together");

    	assert property (@(posedge clk) !(status[0] && status[4]))
        else $display("FAIL: Zero and Huge asserted together");

    	assert property (@(posedge clk) !(status[0] && status[5]))
        else $display("FAIL: Zero and Inexact asserted together");

    	assert property (@(posedge clk) !(status[1] && status[2]))
        else $display("FAIL: Infinity and NaN asserted together");

    	assert property (@(posedge clk) !(status[1] && status[3]))
        else $display("FAIL: Infinity and Tiny asserted together");

    	assert property (@(posedge clk) !(status[1] && status[4]))
        else $display("FAIL: Infinity and Huge asserted together");

    	assert property (@(posedge clk) !(status[1] && status[5]))
        else $display("FAIL: Infinity and Inexact asserted together");

    	assert property (@(posedge clk) !(status[2] && status[3]))
        else $display("FAIL: NaN and Tiny asserted together");

    	assert property (@(posedge clk) !(status[2] && status[4]))
        else $display("FAIL: NaN and Huge asserted together");

   	assert property (@(posedge clk) !(status[2] && status[5]))
        else $display("FAIL: NaN and Inexact asserted together");

    	assert property (@(posedge clk) !(status[3] && status[4]))
        else $display("FAIL: Tiny and Huge asserted together");

endmodule
