module ledblink(

	input clk
	output LED

);

reg [23:0] cnt;
always @(posedge clk) cnt <= cnt + 24'd1;

assign LED = cnt[23];

endmodule

