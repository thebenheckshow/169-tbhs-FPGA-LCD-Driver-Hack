module BitClock(

	input clk,
	output pair2,
	output pair1,
	output pair0,
	output pairCLK,
	output LED_indicator
	
);

fast_clock		u1
		(	.inclk0(clk),
			.c0(bit_clock_out)
		);


reg [23:0] cnt;
reg out_clock;
reg [3:0] slot = 6;

reg dataEnable = 1'b0;
reg vsync = 1'b0;
reg hsync = 1'b0;

reg [5:0] red = 	6'b000000;
reg [5:0] green = 	6'b000000;
reg [5:0] blue = 	6'b111111;

reg [6:0] RX0data = 7'b0000000;
reg [6:0] RX1data = 7'b0000000;
reg [6:0] RX2data = 7'b0000000;
reg [6:0] CLKdata = 7'b1100011;

reg [15:0] hCurrent = 0;
reg [15:0] hFront = 1024;		//The actual visible pixels
reg [15:0] hSyncPulse = 1140; 	//1200; //1380; //1216;
reg [15:0] hTotal = 1160;		//1220; //1400;	  //1236;

reg [15:0] vCurrent = 0;
reg [15:0] vLines = 309;
reg [15:0] vTotal = 329;

always @*
begin
 
        RX2data[6] <= dataEnable;
        RX2data[5] <= vsync;
        RX2data[4] <= hsync;
        
        RX2data[3:0] <= blue[5:2];
        
        RX1data[6:5] <= blue[1:0];
        RX1data[4:0] <= green[5:1];
        
        RX0data[0] <= green[0];
        RX0data[5:0] <= red[5:0];
 
end

always @(posedge bit_clock_out)
begin

	case(hCurrent)					//Draw white lines on left and right edge

		1:
		begin
			green <= 63;
		end
		2:
		begin
			green <= 63;
		end		
		1023:
		begin
			green <= 63;
		end
		1024:
		begin
			green <= 63;
		end
		default:
		begin
			green <= 0;
		end			

	endcase
	
	case(vCurrent)
		0:
		begin
		red <= 63;
		end
		1:
		begin
		red <= 63;
		end
		308:
		begin
		red <= 63;
		end
		309:
		begin
		red <= 63;
		end	
		311:
		begin
			vsync <= 1'b1;
		end
		312:
		begin
			vsync <= 1'b1;
		end
		default:
		begin
			vsync <= 1'b0;
			red <= 0;
		end

	endcase
	
	if (hCurrent > hFront || vCurrent > vLines)		//Data is only enabled during visible pixels - disabled in H and V porches
		begin
			dataEnable <= 1'b0;
		end
		else
		begin
			dataEnable <= 1'b1;
		end

	if (hCurrent >= hSyncPulse)						//A line ends with 20 pulses of the H sync bit
		begin
			hsync <= 1'b1;
		end
		else
		begin
			hsync <= 1'b0;
		end
	
	if (slot == 0)
	begin
	
		slot <= 6;		
		
		//green <= hCurrent[5:0];
		
		if (hCurrent == hTotal)
		begin
			hCurrent <= 0;			
			if (vCurrent == vTotal)
			begin
				vCurrent <= 0;
				//red <= 0;
			end
			else
			begin
				vCurrent <= vCurrent + 1;
				//red <= red + 1;
				
				//if (red == 63)
				//begin
					//red <= 0;
				//end					
			end		
		end
		else
		begin
			hCurrent <= hCurrent + 1;
		end		
	end
	else
	begin
		slot <= slot - 1;	
	end

	out_clock <= ~out_clock;
	cnt <= cnt + 1'b1;
	
end

assign LED_indicator = 	cnt[23];
assign pair2 =          RX2data[slot];
assign pair1 =          RX1data[slot];
assign pair0 =          RX0data[slot];
assign pairCLK =        CLKdata[slot];

endmodule

