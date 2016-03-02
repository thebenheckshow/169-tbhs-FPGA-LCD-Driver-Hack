module SD_FPGA(

		clock_50r,						//	50 MHz rising edge
		clock_50f,						//	50 MHz falling edge

		SD_OUT,
		SD_IN,
		SD_CLK,
		SD_CS,

		switches,
		sw9,
		
		////////////////////	7-SEG Dispaly	////////////////////
		HEX0_D,							//	Seven Segment Digit 0
		HEX1_D,							//	Seven Segment Digit 1
		HEX2_D,							//	Seven Segment Digit 2
		HEX3_D,							//	Seven Segment Digit 3
		
);

input clock_50r;
input clock_50f;

input wire [8:0] switches;
input wire sw9;

output	[6:0]	HEX0_D;					//	Seven Segment Digit 0
output	[6:0]	HEX1_D;					//	Seven Segment Digit 1
output	[6:0]	HEX2_D;					//	Seven Segment Digit 3
output	[6:0]	HEX3_D;					//	Seven Segment Digit 4

output reg SD_OUT;
input wire SD_IN;
output reg SD_CLK;
output reg SD_CS;

reg [15:0] hexDisplay;

reg [31:0] counter = 0;
reg [31:0] timer = 0;

reg [31:0] stateSD = 0;

wire [7:0] byteIn;							//The byte we're sending
reg [7:0] byteOut;					//The byte we're getting

reg [7:0] commandOut [0:9];				//Six byte commandOut, eight null bytes for read, 10 bytes for 80 clock pulse SD boot
reg [7:0] sector [0:127];					//Eight byte response
reg [10:0] byteTarget;						//Can get up to 512 data + 2 CRC bytes
reg runFlag = 0;
reg commandFlag = 1;							//0 = spits out endless FF, 1 = spits out 6 Command Bytes

reg [10:0] byteWhich = 0;					//Which byte we are currently sending / getting
reg [3:0] bitWhich = 7;						//Which bit we're on (7-0)
reg [3:0] bitPulse = 3;						//Which pulse in the bit we're on (0-3)

reg [7:0] bitPattern = 8'b10011001;

reg dataClock = 0;


always @ (posedge clock_50r)
begin

	case(stateSD)
		0:
			begin
				SD_CS <= 1'b1;
				commandFlag <= 0;				
				byteTarget <= 10;
				runFlag <= 1;				
				stateSD <= 1;
			end			
		1:
			begin
				if (byteWhich == byteTarget)
				begin
					stateSD <= 2;
					runFlag <= 0;
					timer <= 0;
				end
				else
				begin
					stateSD <= 1;
				end
			end	
		2:
			begin
				if (timer == 100000)
				begin
					timer <= 0;
					stateSD <= 3;
				end
				else
				begin
					timer <= timer + 1;
					stateSD <= 2;
				end
			end
		3:
			begin
				sendCommand(0, 0, 8'h95);		
				stateSD <= 4;
			end
		4:
			begin
				if (byteWhich == byteTarget)
				begin
					runFlag <= 0;
					SD_CS <= 1;
					stateSD <= 5;	
				end
				else
				begin
					stateSD <= 4;
				end
			end
		5:
			begin
				SD_CS <= 0;
				commandFlag <= 0;				
				byteTarget <= 8;
				runFlag <= 1;				
				stateSD <= 6;
			end	
		6:
			begin
				if (byteWhich == byteTarget)
				begin
					runFlag <= 0;
					SD_CS <= 1;
					stateSD <= 7;						
				end
				else
				begin
					stateSD <= 6;
				end
			end
		7:
			begin			
				sendCommand(8, 32'h0000_01AA, 8'h87);
				stateSD <= 8;
			end
		8:
			begin
				if (byteWhich == byteTarget)
				begin
					runFlag <= 0;
					SD_CS <= 1;
					stateSD <= 9;	
				end
				else
				begin
					stateSD <= 8;
				end
			end
		9:
			begin
				SD_CS <= 0;
				commandFlag <= 0;				
				byteTarget <= 8;
				runFlag <= 1;				
				stateSD <= 10;
			end	
		10:
			begin
				if (byteWhich == byteTarget)
				begin
					runFlag <= 0;
					SD_CS <= 1;
					stateSD <= 11;						
				end
				else
				begin
					stateSD <= 10;
				end
			end			
		11:
			begin
				sendCommand(55, 0, 255);
				stateSD <= 12;
			end
		12:
			begin
				if (byteWhich == byteTarget)
				begin
					runFlag <= 0;
					SD_CS <= 1;
					stateSD <= 13;	
				end
				else
				begin
					stateSD <= 12;
				end
			end
		13:
			begin
				SD_CS <= 0;
				commandFlag <= 0;				
				byteTarget <= 8;
				runFlag <= 1;				
				stateSD <= 14;
			end	
		14:
			begin
				if (byteWhich == byteTarget)
				begin
					runFlag <= 0;
					SD_CS <= 1;
					stateSD <= 15;						
				end
				else
				begin
					stateSD <= 14;
				end
			end		
		15:
			begin
				sendCommand(41, 32'h4000_0000, 255);
				stateSD <= 16;
			end
		16:
			begin
				if (byteWhich == byteTarget)
				begin
					runFlag <= 0;
					SD_CS <= 1;
					stateSD <= 17;	
				end
				else
				begin
					stateSD <= 16;
				end
			end
		17:
			begin
				SD_CS <= 0;
				commandFlag <= 0;				
				byteTarget <= 8;
				runFlag <= 1;				
				stateSD <= 18;
			end	
		18:
			begin
				if (byteWhich == byteTarget)
				begin
					runFlag <= 0;
					SD_CS <= 1;
					stateSD <= 19;						
				end
				else
				begin
					stateSD <= 18;
				end
			end	
		19:
			begin
				sendCommand(1, 0, 255);
				stateSD <= 20;
			end
		20:
			begin
				if (byteWhich == byteTarget)
				begin
					runFlag <= 0;
					SD_CS <= 1;
					stateSD <= 21;	
				end
				else
				begin
					stateSD <= 20;
				end
			end
		21:
			begin
				SD_CS <= 0;
				commandFlag <= 0;				
				byteTarget <= 8;
				runFlag <= 1;				
				stateSD <= 22;
			end	
		22:
			begin
				if (byteWhich == byteTarget)
				begin
					runFlag <= 0;
					SD_CS <= 1;
					stateSD <= 23;						
				end
				else
				begin
					stateSD <= 22;
				end
			end				
		23:
			begin
				if (sector[1] != 8'h00)
				begin
					stateSD <= 19;
				end
				else
				begin
					stateSD <= 24;
				end
			end
		24:
			begin
				sendCommand(16, 512, 255);
				stateSD <= 25;
			end
		25:
			begin
				if (byteWhich == byteTarget)
				begin
					runFlag <= 0;
					SD_CS <= 1;
					stateSD <= 26;	
				end
				else
				begin
					stateSD <= 25;
				end
			end
		26:
			begin
				SD_CS <= 0;
				commandFlag <= 0;				
				byteTarget <= 8;
				runFlag <= 1;				
				stateSD <= 27;
			end	
		27:
			begin
				if (byteWhich == byteTarget)
				begin
					runFlag <= 0;
					SD_CS <= 1;
					stateSD <= 28;						
				end
				else
				begin
					stateSD <= 27;
				end
			end				
		28:
			begin
				if (sector[1] != 8'h00)
				begin
					stateSD <= 0;
				end
				else
				begin
					stateSD <= 50;
				end
			end	
		50:
			begin
				sendCommand(17, 8192, 255);
				stateSD <= 51;
			end
		51:
			begin
				if (byteWhich == byteTarget)
				begin
					runFlag <= 0;
					SD_CS <= 1;
					stateSD <= 52;	
				end
				else
				begin
					stateSD <= 51;
				end
			end
		52:
			begin
				SD_CS <= 0;
				commandFlag <= 0;				
				byteTarget <= 1;
				runFlag <= 1;				
				stateSD <= 53;
			end					
		53:
			begin
				if (byteWhich == byteTarget)
				begin
					runFlag <= 0;
					if (sector[0] == 8'hFE)
					begin
						stateSD <= 54;	
					end
					else
					begin
						stateSD <= 52;	
					end									
				end
				else
				begin
					stateSD <= 53;
				end
			end				
		54:
			begin			
				byteTarget <= 128;
				runFlag <= 1;				
				stateSD <= 55;
			end		
		55:
			begin
				if (byteWhich == byteTarget)
				begin
					runFlag <= 0;
					SD_CS <= 1;
					stateSD <= 99;	
				end
				else
				begin
					stateSD <= 55;
				end
			end
	
		99:
			begin
				stateSD <= 99;
			end			
		default:
			begin
				stateSD <= stateSD + 1;				
			end				
	endcase

end

always @ (posedge clock_50r)
begin

	if (runFlag == 1'b1)
	begin
	
		if (byteWhich < byteTarget)
		begin

			counter <= 0;

			if (commandFlag == 1'b1)
			begin
				byteOut <= commandOut[byteWhich];	
			end
			else
			begin
				byteOut <= 8'b11111111;
			end
			
			if (bitPulse == 0)
			begin

				bitPulse <= 3;
				
				sector[byteWhich][bitWhich] <= SD_IN;
				
				if (bitWhich == 0)
				begin
				
					bitWhich <= 7;				
					byteWhich <= byteWhich + 1;
					
				end
				else
				begin
					bitWhich <= bitWhich - 1;
				end
							
			end
			else
			begin
				bitPulse <= bitPulse - 1;
			end

		end
		else
		begin
			counter <= counter + 1;
		end

	end
	else
	begin
		byteWhich <= 0;	
	end
	
	SD_CLK <= bitPattern[bitPulse];
	SD_OUT <= byteOut[bitWhich];	
	
	if (sw9 == 1'b1)
	begin
		hexDisplay[15:8] <= byteWhich[7:0];
		hexDisplay[7:4] <= bitWhich[3:0];
		hexDisplay[3:0] <= bitPulse[3:0];
	end
	else
	begin
		hexDisplay[15:8] <= sector[switches][7:0];
		hexDisplay[7:0] <= sector[switches + 1][7:0];	
	end
		
end


task sendCommand;

	input [5:0] commandNumber;
	input [31:0] parameterNumber;
	input [7:0] CRCnumber;

	begin
	
		commandFlag <= 1;

		SD_CS <= 0;
		
		commandOut[0][7:0] = commandNumber[5:0] | 8'b0100_0000;
		commandOut[1][7:0] = parameterNumber[31:24];	
		commandOut[2][7:0] = parameterNumber[23:16];	
		commandOut[3][7:0] = parameterNumber[15:8];			
		commandOut[4][7:0] = parameterNumber[7:0];	
		commandOut[5][7:0] = CRCnumber[7:0];	

		byteTarget <= 6;

		runFlag <= 1;
	
	end
	
endtask





slow_SD	u0 (

	.inclk0(clock_50r),
	.c0(clock_400k)

);

SEG7_LUT_2	u1
		(	.oSEG0(HEX0_D),
			.oSEG1(HEX1_D),
			.oSEG2(HEX2_D),
			.oSEG3(HEX3_D),			
			.hexDigits(hexDisplay)
		);


endmodule


