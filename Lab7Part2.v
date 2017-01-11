// Part 2 skeleton

module Lab7Part2(
		CLOCK_50,						//	On Board 50 MHz
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B,   						//	VGA Blue[9:0]
		KEY,
		SW
	);

	input	CLOCK_50;				//	50 MHz
	input [9:0] SW;
	input [3:0] KEY;
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire reset;
	assign reset = KEY[0];

	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire go;
	reg plot;
	assign go = ~KEY[3];
	assign colour = SW[9:7];
	wire Lx,Ly,Lc,enbl;
	wire [2:0] DataColor;
	
	always@(*)
	begin
	case (~KEY[2])
		1'b1: plot = 1'b1;
		1'b0: plot = ~KEY[1];
	 default: plot = ~KEY[1];
	endcase
	end
	
	vga_adapter VGA(
			.resetn(reset),
			.clock(CLOCK_50),
			.colour(DataColor),
			.x(x),
			.y(y),
			.plot(plot),
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	control block0(
						 .L_X(Lx),
					         .L_Y(Ly),
						 .plot(plot),
						 .L_C(Lc),
						 .enable(enbl),
						 .go(go),
						 .resetn(reset),
						 .clk(CLOCK_50)
						 );
						 
	datapath block1(
						 .L_X(Lx),
						 .L_Y(Ly),
					         .L_C(Lc),
						 .L_B(~KEY[2]),
						 .Xin(SW[6:0]),
						 .Yin(SW[6:0]),
						 .enable(enbl),
						 .plot(plot),
						 .resetn(reset),
						 .clk(CLOCK_50),
						 .Xout(x),
						 .Yout(y),
						 .color(colour),
						 .Cout(DataColor)
							);
	
	
endmodule

module control(L_X,L_Y,plot,L_C,enable,go, resetn,clk);

input clk,go ,resetn, plot;
output reg enable, L_X,L_C,L_Y;


reg [3:0] current_state, next_state;
  	 
	
	localparam  S_LOAD_X       = 3'd0,
            	    S_LOAD_WAIT_X  = 3'd1,
            	    S_LOAD_Y   	   = 3'd2,
         	    S_LOAD_WAIT_Y  = 3'd3,
		    CYCLE_0        = 3'd4,
		    S_DONE         = 3'd5;
					
	always@(*)
	begin: state_table
        	case (current_state)
             	S_LOAD_X: next_state = go ? S_LOAD_WAIT_X : S_LOAD_X;                            	
                S_LOAD_WAIT_X: next_state = go ? S_LOAD_WAIT_X : S_LOAD_Y; 
		S_LOAD_Y: next_state = go ? S_LOAD_WAIT_Y : S_LOAD_Y;    
		S_LOAD_WAIT_Y: next_state = go ? S_LOAD_WAIT_Y : CYCLE_0; 
		CYCLE_0: next_state = S_DONE;
		S_DONE: next_state = S_LOAD_X;
                                            	                                     	
        	default: next_state = S_LOAD_X;
			endcase
	end
   

always @(*)
	begin: enable_signals
    	// By default make all our signals 0
    	L_X = 1'b0;
        enable = 1'b0;
        L_C = 1'b0;
	L_Y = 1'b0;
  
 
    	case (current_state)
        	S_LOAD_X: begin
                L_X = 1'b1;
                L_C = 1'b1;
		enable = 1'b0;	
		L_Y = 1'b0;
	        end
						  
			S_LOAD_Y: begin
                        L_X = 1'b0;
                        L_C = 1'b0;
			enable = 1'b0;	
			L_Y = 1'b1;
			end
						  
			CYCLE_0: begin
                        L_X = 1'b0;
                        L_C = 1'b0;
			enable = 1'b1;	
			L_Y = 1'b0;
			end
						  
			S_DONE: begin
                        L_X = 1'b0;
                        L_C = 1'b0;
			enable = 1'b1;	
			L_Y = 1'b0;
			end
	  endcase
	end
					
// current_state registers
	always@(posedge clk)
	begin: state_FFs
    	if(!resetn)
        	current_state <= S_LOAD_X;
    	else
        	current_state <= next_state;
	end // state_FFS
endmodule 


module datapath(L_X,L_Y,L_C,L_B,Xin,Yin,enable,plot,resetn,clk,Xout,Yout,color,Cout);

input L_X,L_Y,L_C,L_B,enable,plot,resetn,clk;
input [2:0] color;
input [6:0] Xin;
input [6:0] Yin;
output reg [7:0] Xout;
output reg [6:0] Yout;
output reg [2:0] Cout;
reg [2:0] regColor;
reg [7:0] Xorigin;
reg [6:0] Yorigin;
reg [3:0] counter;
reg [2:0] regBlack;
reg [14:0] counterBlack;


always@(posedge clk)
	begin
	if(!resetn)
		begin
			Xorigin <= 8'b0;
			Yorigin <= 7'b0;
			regColor <= 3'b0;
		end
	else
	 begin
	 if(L_X)
		Xorigin <= {1'b0,Xin};
	 if(L_Y)
		Yorigin <= Yin;
	 if(L_C)
		regColor <= color;
	 end
	end
	
always@ (posedge clk)
	begin
	
	if(L_B)
	begin
	 counterBlack <= counterBlack + 1'b1;
	  Xout <= counterBlack[7:0];
	  Yout <= counterBlack[14:8];
	  Cout<= 3'b000;
	end
	else 
	begin
	if(plot)
		begin
			if(!resetn)
				begin
				Xout <= 8'b0;
				Yout <= 7'b0;
				counter <= 4'b0;
				Cout <= 3'b0; 
				counterBlack <= 15'b0;
				end
			if(counter <= 4'b1111)
				begin
				counterBlack <= 15'b0;
				Cout <= regColor  + 1'b0;
				Xout<= Xorigin + counter[1:0];
				Yout<= Yorigin + counter[3:2];
				counter <= counter + 1'b1;
				end
			else
				begin
				 Xout <= Xout;
				 Yout <= Yout;
				 Cout <= 3'b0;
				end
		end
	else
	 begin
	 Xout <= Xout;
	 Yout <= Yout;
	 end
	end
end
endmodule 
