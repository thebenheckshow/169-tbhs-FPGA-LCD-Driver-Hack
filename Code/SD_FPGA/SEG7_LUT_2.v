module SEG7_LUT_2 (	oSEG0, oSEG1, oSEG2, oSEG3, hexDigits );

input	[15:0] hexDigits;

output	[6:0]	oSEG0, oSEG1, oSEG2, oSEG3;

SEG7_LUT	u0	(	oSEG2, hexDigits[11:8]	);
SEG7_LUT	u1	(	oSEG3, hexDigits[15:12]	);

SEG7_LUT	u2	(	oSEG0, hexDigits[3:0]	);
SEG7_LUT	u3	(	oSEG1, hexDigits[7:4]	);


endmodule