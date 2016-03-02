module LEDG_Driver(oLED,iCLK,iRST_n);
output	[9:0]	oLED;
input			iCLK;
input			iRST_n;

reg		[20:0]	Cont;
reg		[9:0]	mLED;
reg				DIR;

always@(posedge iCLK)	Cont	<=	Cont+1'b1;

always@(posedge Cont[20] or negedge iRST_n)
begin
	if(!iRST_n)
	begin
		mLED	<=	10'b0000000111;
		DIR		<=	0;
	end
	else
	begin
		if(!DIR)
		mLED	<=	{mLED[8:0],mLED[9]};
		else
		mLED	<=	{mLED[0],mLED[9:1]};
		if(mLED == 10'b0111000000)
		DIR	<=	1;
		else if(mLED == 10'b0000001110)
		DIR	<=	0;
	end
end

assign	oLED	=	mLED;

endmodule
