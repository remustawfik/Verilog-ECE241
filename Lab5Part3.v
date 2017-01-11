`timescale 1ns / 1ns 

module Lab5Part3(SW,KEY,LEDR,CLOCK_50);

	input [9:0] SW;
	input [2:0] KEY;
	input CLOCK_50;
	output [9:0] LEDR;
	
	wire clear1,Enable;
	wire resetm;
	wire [2:0] LetSelect;
	wire MorseOut;
	reg [10:0] LettersIn;
	wire muxS;
	
	reg [24:0] count1;
	
	
	assign resetm = ~KEY[0];
	assign muxS = ~KEY[1];
	assign LetSelect = SW[2:0];
	assign LEDR[0] = MorseOut;
	
	always@(posedge CLOCK_50)
	begin
		if((clear1 == 1'b1)|(resetm == 1'b1))
			count1 <= 25'd0;
		else
			count1 <= count1 + 1'b1;
	end

	assign clear1 = Enable;
	assign Enable = (count1 == 25'd25000000) ? 1'b1 : 1'b0;
	
	always@(*)
	begin
	case(LetSelect)
	3'b000: LettersIn = 11'b10111000000;
	3'b001: LettersIn = 11'b11101010100;
	3'b010: LettersIn = 11'b11101011101;
	3'b011: LettersIn = 11'b11101010000;
	3'b100: LettersIn = 11'b10000000000;
	3'b101: LettersIn = 11'b10101110100;
	3'b110: LettersIn = 11'b11101110100;
	3'b111: LettersIn = 11'b10101010000;
	default:
	LettersIn = 11'b00000000000;
	endcase
	end
	
	MorseCode mainBlock(
			    .muxSel(muxS),
			    .Letters(LettersIn),
			    .MorseO(MorseOut),
			    .clock(Enable),
			    .reset(resetm)
			   );
	
endmodule

//-------------------------------------------------------------------------------
module MorseCode(muxSel,Letters,MorseO,clock,reset);
	
	input [10:0] Letters;
	input muxSel;
	input clock,reset;
	output MorseO;
	wire [9:0] Q;

	register_bit RB10(muxSel,Letters[10],MorseO,Q[9],clock,reset);
	register_bit RB9 (muxSel,Letters[9],Q[9],Q[8],clock,reset);
	register_bit RB8 (muxSel,Letters[8],Q[8],Q[7],clock,reset);
	register_bit RB7 (muxSel,Letters[7],Q[7],Q[6],clock,reset);
	register_bit RB6 (muxSel,Letters[6],Q[6],Q[5],clock,reset);
	register_bit RB5 (muxSel,Letters[5],Q[5],Q[4],clock,reset);
	register_bit RB4 (muxSel,Letters[4],Q[4],Q[3],clock,reset);
	register_bit RB3 (muxSel,Letters[3],Q[3],Q[2],clock,reset);
	register_bit RB2 (muxSel,Letters[2],Q[2],Q[1],clock,reset);
	register_bit RB1 (muxSel,Letters[1],Q[1],Q[0],clock,reset);
	register_bit RB0 (muxSel,Letters[0],Q[0],1'b0,clock,reset);


endmodule

//-------------------------------------------------------------------------------
module register_bit(muxSelect, LetterSelect, MorseOut,Q,clockMOFO,resetMOFO);
	
	input muxSelect,resetMOFO,clockMOFO;
	input LetterSelect,Q;
	output reg MorseOut; 
	wire decision;

	mux2to1 doggo1(LetterSelect,Q, muxSelect, decision);
	
	always@(posedge clockMOFO)
	begin
	if(resetMOFO == 1'b1)
	MorseOut <= 1'b0;
	else
	MorseOut <= decision;
	end
	
endmodule

//-----------------------------------------------------------------------------------
module mux2to1(x, y, s, m);
    input x; //select 0
    input y; //select 1
    input s; //select signal
    output m; //output
  
    //assign m = s & y | ~s & x;
    // OR
    assign m = s ? y : x;

endmodule
