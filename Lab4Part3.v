

module Lab4Part3(SW, LEDR, KEY);

	input [9:0]SW; 
	input [3:0] KEY;
	output [9:0] LEDR;
	wire mainclock,resetmain,loadnmain,shiftRmain;
	wire [7:0] Qmain;
	wire [7:0] DATA_INmain;
	wire ASRight;

	assign mainclock = ~KEY[0];
	assign loadnmain = ~KEY[1];
	assign shiftRmain = ~KEY[2];
	assign ASRight = ~KEY[3];
	assign resetmain = SW[9];
	assign DATA_INmain = SW[7:0];
	assign LEDR[7:0] = Qmain;
	
	
	AS_input scissors(
							.ASin(ASRight),
							.Q(Qmain),
							.DATA_IN(DATA_INmain),
							.shiftR(shiftRmain),
							.loadn(loadnmain),
							.clock(mainclock),
							.reset(resetmain)
							);

	
endmodule 

//-------------------------------------------------------------------------------
module AS_input(ASin,Q,DATA_IN, shiftR, loadn, clock, reset);
	input [7:0] DATA_IN;
	input ASin,shiftR,loadn,clock,reset;
	output [7:0] Q;
	wire [7:0] QAS;
	wire [7:0] Qreg;
	
	AS_register smol(QAS,DATA_IN,shiftR, loadn,clock,reset);
	rotate_register toll(Qreg,DATA_IN,shiftR,loadn,clock,reset);

	assign Q = ASin ? QAS : Qreg;


endmodule 

//-------------------------------------------------------------------------------
module AS_register(Qs,DATA_INs,shiftRs,loadns,clocks,resets);

	input [7:0] DATA_INs,shiftRs,loadns,clocks,resets;
	output [7:0] Qs;
	
	register_bit RB7 (DATA_INs[7],Qs[6],Qs[7],DATA_INs[7],shiftRs,loadns,clocks,resets);
	register_bit RB6 (Qs[7],Qs[5],Qs[6],DATA_INs[6],shiftRs,loadns,clocks,resets);
	register_bit RB5 (Qs[6],Qs[4],Qs[5],DATA_INs[5],shiftRs,loadns,clocks,resets);
	register_bit RB4 (Qs[5],Qs[3],Qs[4],DATA_INs[4],shiftRs,loadns,clocks,resets);
	register_bit RB3 (Qs[4],Qs[2],Qs[3],DATA_INs[3],shiftRs,loadns,clocks,resets);
	register_bit RB2 (Qs[3],Qs[1],Qs[2],DATA_INs[2],shiftRs,loadns,clocks,resets);
	register_bit RB1 (Qs[2],Qs[0],Qs[1],DATA_INs[1],shiftRs,loadns,clocks,resets);
	register_bit RB0 (Qs[1],Qs[7],Qs[0],DATA_INs[0],shiftRs,loadns,clocks,resets);

endmodule

//-------------------------------------------------------------------------------
module rotate_register(Q,DATA_IN,shiftR,loadn,clock,reset);

	input [7:0] DATA_IN,shiftR,loadn,clock,reset;
	output [7:0] Q;
	
	register_bit RB7 (Q[0],Q[6],Q[7],DATA_IN[7],shiftR,loadn,clock,reset);
	register_bit RB6 (Q[7],Q[5],Q[6],DATA_IN[6],shiftR,loadn,clock,reset);
	register_bit RB5 (Q[6],Q[4],Q[5],DATA_IN[5],shiftR,loadn,clock,reset);
	register_bit RB4 (Q[5],Q[3],Q[4],DATA_IN[4],shiftR,loadn,clock,reset);
	register_bit RB3 (Q[4],Q[2],Q[3],DATA_IN[3],shiftR,loadn,clock,reset);
	register_bit RB2 (Q[3],Q[1],Q[2],DATA_IN[2],shiftR,loadn,clock,reset);
	register_bit RB1 (Q[2],Q[0],Q[1],DATA_IN[1],shiftR,loadn,clock,reset);
	register_bit RB0 (Q[1],Q[7],Q[0],DATA_IN[0],shiftR,loadn,clock,reset);

endmodule

//-------------------------------------------------------------------------------
module register_bit(right,left, Qr, DATA_INr, shiftRr,loadnr,clockr,resetr);

	input right,left,DATA_INr, shiftRr, loadnr,clockr,resetr;
	output reg Qr;
	wire LRout,Dinput;

	mux2to1 doggo1(right,left,shiftRr,LRout);
	mux2to1 doggo2(DATA_INr,LRout,loadnr,Dinput);

	always@(posedge clockr)

	begin
		if(resetr == 1'b1)
			Qr<=0;
		else
			Qr<= Dinput;
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
