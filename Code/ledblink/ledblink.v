module ledblink(

	input clk,
	output LED


);

reg [23:0] cnt;

pixel_bitclock		u1
		(	.inclk0(clk),
			.c0(bit_clock_out)
		);


always @(posedge bit_clock_out) cnt <= cnt + 24'd1;

assign LED = cnt[23];
endmodule

