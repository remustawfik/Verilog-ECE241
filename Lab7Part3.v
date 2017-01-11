module FixMe
	(
		CLOCK_50,						//	On Board 50 MHz
		SW, 
		KEY, 
		LEDR,
		HEX0,
		HEX1,
		HEX2,
		HEX3,
		HEX4,
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						 //	VGA Blue[9:0]
	);
	
	// Declare your inputs and outputs here
	input [9:0] SW;
	input [3:0] KEY;   
	input CLOCK_50;
   
	output [9:0] LEDR; 
	output [6:0] HEX0,HEX1,HEX2,HEX3,HEX4;
	
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
   
	wire [2:0] colour;
	wire resetn,load_shiftD,load_shiftU,load_shiftR,load_shiftL,load_Del,load_New,load_Reset,letItHappen,enable1,upFlag,rightFLag,load_Done;
	wire [2:0] output_colour;
	wire [7:0] x;
	wire [6:0] y;
	wire [4:0] counter;
	reg [26:0] count1;
	wire [4:0] dataCounter;
	wire clear1;
	assign resetn = KEY[0];
	assign colour=SW[9:7];
	wire DONEMAKE,doughnutMove;
	
	assign LEDR[4:0]= counter;
	
	//always block for clock (every one second)
	
	always @(posedge CLOCK_50) begin
	   if(clear1==1'b1)
		   count1<=26'd0;
	   else
		   count1<=count1+1'b1;
	end
	
	assign clear1=enable1;
	assign enable1=(count1==26'd12500000)?1'b1:1'b0;
	
	hex_decoder H0(
        .hex_digit(x[3:0]), 
        .segments(HEX0)
        );
	hex_decoder H1(
        .hex_digit(x[7:4]), 
        .segments(HEX1)
	);	
        hex_decoder H2(
        .hex_digit(y[3:0]), 
        .segments(HEX2)
        );
	hex_decoder H3(
        .hex_digit(y[6:4]), 
        .segments(HEX3)
        );		
        hex_decoder H4(
        .hex_digit(dataCounter[3:0]), 
        .segments(HEX4)
        );		     			
	

	// Create an Instance of a VGA controller - there can be only one!
	control c0(CLOCK_50,resetn,load_shiftD,load_shiftU,load_shiftR,load_shiftL,load_Del,load_New,load_Reset,load_Done,letItHappen,enable1,upFlag,rightFLag,DONEMAKE,doughnutMove);
	datapath d0(CLOCK_50,resetn,load_shiftD,load_shiftU,load_shiftR,load_shiftL,load_Del,load_New,load_Reset,load_Done,upFlag,rightFLag,output_colour,x,y,colour,LEDR[9],dataCounter,DONEMAKE,doughnutMove);
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(output_colour),
			.x(x),
			.y(y),
			.plot(letItHappen),
			/* Signals for the DAC to drive the monitor. */
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
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn
	// for the VGA controller, in addition to any other functionality your design may require.
		
endmodule

module control (clock,resetn, 
   load_shiftD,      
   load_shiftU,
   load_shiftR,
   load_shiftL,
   load_Del,
   load_New,
   load_Reset,
   load_Done,
   letItHappen, 
   enable1,
   upFlag,
   rightFlag,
   DONEMAKINSQUARE,
   doughnutMove);

	input clock,resetn,enable1,upFlag,rightFlag,DONEMAKINSQUARE,doughnutMove;
	output reg    load_shiftD,load_shiftU,load_shiftR,load_shiftL,load_Del,load_New,letItHappen,load_Done,load_Reset;
	reg [5:0] current_state, next_state; 
    
    localparam  S_Reset         = 5'd0, 
					 S_DeleteOld     = 5'd1,
					 S_StartAnimation= 5'd2,                
                S_ShiftUp       = 5'd3,
					 S_ShiftDown     = 5'd4,
					 S_ShiftRight    = 5'd5,
                S_ShiftLeft     = 5'd6,
					 S_PrintNew      = 5'd7,
					 S_Done          = 5'd8;
					 
					
					 
always@(*)
   
 begin: state_table 
       
     case (current_state)
           
		S_Reset: next_state = S_DeleteOld;
		
		S_DeleteOld: next_state =  doughnutMove ? S_StartAnimation : S_DeleteOld;
		
		S_StartAnimation: next_state = upFlag? S_ShiftUp : S_ShiftDown;
		
                S_ShiftUp: next_state = rightFlag? S_ShiftRight : S_ShiftLeft; 
  
                S_ShiftDown: next_state = rightFlag? S_ShiftRight : S_ShiftLeft; 
		
		S_ShiftLeft: next_state = S_PrintNew;
		
		S_ShiftRight: next_state = S_PrintNew;
	   
		S_PrintNew: next_state =  DONEMAKINSQUARE ? S_Done : S_PrintNew ;
		
		S_Done: next_state = enable1? S_DeleteOld: S_Done;
		
		
		default:
			next_state=S_StartAnimation;
			
		endcase
 end
 
// Output logic aka all of our datapath control signals
   
always @(*)
  
  begin: enable_signals
       // By default make all our signals 0
      
  load_shiftD=1'b0;       
  load_shiftU=1'b0;
  load_shiftR=1'b0;
  load_shiftL=1'b0;
  load_Del=1'b0;
  load_New=1'b0;
  load_Reset = 1'b0;
  letItHappen = 1'b0;
  load_Done = 1'b0; 
  
  
 case (current_state)
           
	S_ShiftDown: begin
	
      letItHappen = 1'b0;     
		load_shiftU=1'b0;
		load_shiftR=1'b0;
		load_shiftL=1'b0;
		load_Del=1'b0;
		load_New=1'b0;
		load_Reset = 1'b0;
		load_shiftD = 1'b1; 
		load_Done = 1'b0;
   end
	
	S_ShiftUp: begin
		  load_shiftD=1'b0;       
		  letItHappen = 1'b0;
		  load_shiftR=1'b0;
		  load_shiftL=1'b0;
		  load_Del=1'b0;
		  load_New=1'b0;
		  load_Reset = 1'b0;
		  load_shiftU = 1'b1; 
		  load_Done = 1'b0;
   end
	
	S_ShiftRight: begin
		load_shiftD=1'b0;       
	  load_shiftU=1'b0;
	  load_shiftL=1'b0;
	  load_Del=1'b0;
	  load_New=1'b0;
	  load_Reset = 1'b0;
	  letItHappen = 1'b0;
		load_shiftR = 1'b1; 
		load_Done = 1'b0;
   end
	
   S_ShiftLeft: begin
	  load_shiftD=1'b0;       
	  load_shiftU=1'b0;
	  load_shiftR=1'b0;
	  load_Del=1'b0;
	  load_New=1'b0;
	  load_Reset = 1'b0;
	  letItHappen = 1'b0;
          load_Done = 1'b0;
          load_shiftL = 1'b1; 
   end
	
   S_DeleteOld: begin
	  load_shiftD=1'b0;       
	  load_shiftU=1'b0;
	  load_shiftR=1'b0;
	  load_shiftL=1'b0;
	  load_New=1'b0;
	  load_Reset = 1'b0;  
	  load_Done = 1'b0;
          load_Del = 1'b1;
	  letItHappen = 1'b1;
		
   end
	
   S_PrintNew: begin
 
	 load_shiftD=1'b0;       
	 load_shiftU=1'b0;
	 load_shiftR=1'b0;
	 load_shiftL=1'b0;
	 load_Del=1'b0;
	 load_Reset = 1'b0;
	 load_Done = 1'b0;
         load_New = 1'b1;
         letItHappen = 1'b1;
		
   end
   S_Reset: begin
	
	 load_shiftD=1'b0;       
	 load_shiftU=1'b0;
	 load_shiftR=1'b0;
	 load_shiftL=1'b0;
	 load_Del=1'b0;
	 load_New=1'b0;
	 letItHappen = 1'b0;
	 load_Reset = 1'b1; 
	 load_Done = 1'b0;
		
   end
   S_Done: begin
	
	load_shiftD=1'b0;       
        load_shiftU=1'b0;
  	load_shiftR=1'b0;
  	load_shiftL=1'b0;
  	load_Del=1'b0;
  	load_New=1'b0;
  	load_Reset = 1'b0;
  	letItHappen = 1'b0;
  	load_Done = 1'b1; 
   end
endcase
end

// current_state registers
  
always@(posedge clock)
  
   begin: state_FFs
     
      if(!resetn)       
         current_state <= S_Reset; 
      else            
		   current_state <= next_state;
 
   end // state_FFS


endmodule

module datapath(clock,resetn,load_shiftD,load_shiftU,load_shiftR,load_shiftL,load_Del,load_New,load_Reset,load_Done,upFlag,rightFlag,output_colour,otherX,otherY,colour,marker,counter,DONEMAKINSQUARE,doughnutMove);

	input [2:0] colour;
	input clock,resetn,load_shiftD,load_shiftU,load_shiftR,load_shiftL,load_Del,load_New,load_Reset,load_Done;
	output reg upFlag, rightFlag,DONEMAKINSQUARE,doughnutMove;
	output reg [2:0] output_colour;
	 reg [7:0] x_reg;
	 reg [6:0] y_reg;
	output reg [7:0] otherX;
	output reg [6:0] otherY;
	reg [14:0] counterBlack;
	output reg [4:0] counter;
	reg [15:0] counter1;
	reg L_B,plot;
	reg [7:0] x_old;
	reg [6:0] y_old;
	
	
	//reg [4:0] counter;
	//output [4:0] countOut;
   //assign countOut[4:0]=counter[4:0];
	
	output reg marker;
	
always@(posedge clock) begin

   if(load_shiftD) begin	
      counter<=5'b00000;
		counter1<=5'b00000;
		doughnutMove <= 1'b0;
      DONEMAKINSQUARE <= 1'b0;		
		y_reg<=y_reg+1'b1;
		if(y_reg==7'd116)
		   upFlag=1'b1;			
	end
	
   if(load_shiftU) begin	
	   counter<=5'b00000;
		counter1<=5'b00000;
		doughnutMove <= 1'b0;
		DONEMAKINSQUARE <= 1'b0;
      y_reg<=y_reg-1'b1;
		if(y_reg==7'b0)
		   upFlag=1'b0;			
	end
	
	if(load_shiftR) begin
	 counter<=5'b00000;
	 counter1<=5'b00000;
	 doughnutMove <= 1'b0;
	 DONEMAKINSQUARE <= 1'b0;
		x_reg<=x_reg+1'b1;
		if(x_reg==8'd156)
		   rightFlag=1'b0;		
	end
	
	if(load_shiftL) begin
	   counter<=5'b00000;
		counter1<=5'b00000;
		doughnutMove <= 1'b0;
		DONEMAKINSQUARE <= 1'b0;
	   x_reg<=x_reg-1'b1;
		if(x_reg==8'b0)
		   rightFlag=1'b1;
	end
	
	if(load_Del) begin
	   //otherX<=x_reg[7:0];
		//otherY<=y_reg[6:0];
		if(counter1 <= 16'b0111111111111111)
				begin
				otherX<= counter1[7:0] ;
				otherY<= counter1[14:8] ;
				counter1 <= counter1 + 1'b1;
				output_colour <= 3'b000;
				end
		if(counter1 == 16'b1000000000000000)
		begin
			doughnutMove <= 1'b1;
		end
	   //x_reg<=otherX[7:0]+counter[1:0];
		//y_reg<=otherY[6:0]+counter[3:2];
		//counter[4:0]<=counter[4:0]+1'b1;
		//output_colour <= 3'b000;
		
		
	end
	
	if(load_New) begin
	  // otherX<=x_reg[7:0];
	  //otherY<=y_reg[6:0];
		
		x_old <= x_reg;
		y_old <= y_reg;
		if(counter <= 5'b01111)
				begin
				otherX<= x_reg + counter[1:0];
				otherY<= y_reg + counter[3:2];
				counter <= counter + 1'b1;
				end
		if(counter == 5'b10000)
		begin
	   DONEMAKINSQUARE <= 1'b1;
		counter<=5'b00000;
		end
		//otherX<=x_reg[7:0]+counter[1:0];
		//otherY<=y_reg[6:0]+counter[3:2];
		//counter[4:0]<=counter[4:0]+1'b1;
		output_colour <= colour;
	   plot <= 1'b1;
	end
	
	if(load_Reset) begin
	   counter<=5'b0000;
	   counter1<=5'b00000;	
	   x_reg <= 8'b0; 
      y_reg <= 7'b0;
		doughnutMove <= 1'b0;
	   rightFlag <= 1'b1;
	   upFlag <= 1'b0;
	   DONEMAKINSQUARE <= 1'b0;	
	end
	
	if(load_Done) begin
	   //counter<=5'b00000;
		marker<=1;
	end
end
//
//	always@ (*)
//	begin
//	
//	if(L_B)
//	begin
//	 counterBlack <= counterBlack + 1'b1;
//	 otherX <= counterBlack[7:0];
//	 otherY <= counterBlack[14:8];
//	 output_colour<= 3'b000;
//	end
//	else 
//	begin
//	if(plot)
//		begin
//			if(!resetn)
//				begin
//				otherX <= 8'b0;
//				otherY <= 7'b0;
//				counter <= 4'b0;
//				output_colour <= 3'b0; 
//				counterBlack <= 15'b0;
//				end
//			if(counter <= 4'b1111)
//				begin
//				counterBlack <= 15'b0;
//				output_colour <= colour + 1'b0;
//				otherX<= x_origin + counter[1:0];
//				otherY<= y_origin + counter[3:2];
//				counter <= counter + 1'b1;
//				end
//			else
//				begin
//				 otherX <= otherX;
//				 otherY <= otherY;
//				 output_colour <= 3'b0;
//				end
//		end
//	else
//	 begin
//	 otherX <= otherX;
//	 otherY <= otherY;
//	 end
//	end
//end

endmodule

module hex_decoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;
   
    always @(*)
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;   
            default: segments = 7'h7f;
        endcase
endmodule
