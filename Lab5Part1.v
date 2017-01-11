`timescale 1ns / 1ns 


module Lab5Part1(SW,KEY,LEDR,HEX0,HEX1);

	input [9:0] SW;
	input [3:0] KEY;
	output [9:0] LEDR;
	output [6:0] HEX0;
	output [6:0] HEX1;
	wire [7:0] Qin;
	
	
	HEX_NUM hex0(
			.a(Qin[3]),
			.b(Qin[2]),
			.c(Qin[1]),
			.d(Qin[0]),
			.H0(HEX0[0]),
			.H1(HEX0[1]),
			.H2(HEX0[2]),
			.H3(HEX0[3]),
		        .H4(HEX0[4]),
			.H5(HEX0[5]),
			.H6(HEX0[6])
		     );
						
	HEX_NUM hex1(
			.a(Qin[7]),
			.b(Qin[6]),
			.c(Qin[5]),
			.d(Qin[4]),
			.H0(HEX1[0]),
			.H1(HEX1[1]),
			.H2(HEX1[2]),
			.H3(HEX1[3]),
			.H4(HEX1[4]),
			.H5(HEX1[5]),
			.H6(HEX1[6])
		     );
					
       ate_bit_counter final(
			.Enable(SW[1]),
			.clock(~KEY[0]),
			.clear_b(SW[0]),
			.Q(Qin)
		     );
	
	
endmodule

module ate_bit_counter(Enable, clock,clear_b,Q);
	input Enable,clock,clear_b;
	output [7:0] Q;
	wire [6:0] AND_out;
	
	
	T_FF block7(clock,Q[0],Enable,clear_b);
	assign AND_out[6] = Enable & Q[0];
	
	T_FF block6(clock,Q[1],AND_out[6],clear_b);
	assign AND_out[5] = AND_out[6] & Q[1];
	
	T_FF block5(clock,Q[2],AND_out[5],clear_b);
	assign AND_out[4] = AND_out[5] & Q[2];
	
	T_FF block4(clock,Q[3],AND_out[4],clear_b);
	assign AND_out[3] = AND_out[4] & Q[3];
	 
	T_FF block3(clock,Q[4],AND_out[3],clear_b);
	assign AND_out[2] = AND_out[3] & Q[4];
	
	
	T_FF block2(clock,Q[5],AND_out[2],clear_b);
	assign AND_out[1] = AND_out[2] & Q[5];
	
	
	T_FF block1(clock,Q[6],AND_out[1],clear_b);
	assign AND_out[0] = AND_out[1] & Q[6];
	
	T_FF block0(clock,Q[7],AND_out[0],clear_b);

endmodule 


module T_FF(clock,Qout,T,clear_b);

	input clock,T,clear_b;
	output reg Qout;
	reg XOR_out;
	
	always@(*)
	begin
		XOR_out = T ^ Qout;
	end
	
	
	always@(posedge clock)
	begin
	
	if(clear_b == 1'b0)
	
		Qout<= 1'b0;
		
	else
		Qout<= XOR_out;
	end
	

endmodule 


//Hex functionality
module HEX_NUM(a,b,c,d, H0,H1,H2,H3,H4,H5,H6);

	input a,b,c,d;
	output H0,H1,H2,H3,H4,H5,H6;
	
   h0_block HB0(a, b, c, d,H0);
   h1_block HB1(a, b, c, d,H1);
   h2_block HB2(a, b, c, d,H2);
   h3_block HB3(a, b, c, d,H3);
   h4_block HB4(a, b, c, d,H4);
   h5_block HB5(a, b, c, d,H5);
   h6_block HB6(a, b, c, d,H6);
	
endmodule
	
module h0_block(a, b, c, d,h0);
    input a; //select 0
    input b; //select 1
    input c; //select signal
    input d;
	 output h0;
		assign h0 = (b | d) & (a | ~c) & (~b|~c) & (~a|d) & (a|~b|~d) & (~a|b|c);
endmodule

module h1_block(a, b, c, d,h1);
    input a; //select 0
    input b; //select 1
    input c; //select signal
    input d;
	 output h1;
		assign h1 = (a | b) & (b | d) & (a|c|d) & (a|~c|~d) & (~a|c|~d);
endmodule

module h2_block(a, b, c, d,h2);
    input a; //select 0
    input b; //select 1
    input c; //select signal
    input d;
	 output h2;
		assign h2 = (a | c) & (a | ~d) & (c|~d) & (a|~b) & (~a|b);
endmodule

module h3_block(a, b, c, d,h3);
    input a; //select 0
    input b; //select 1
    input c; //select signal
    input d;
	 output h3;
		assign h3 = (a|b | d) & (b | ~c|~d) & (~b|c|~d) & (~b|~c|d) & (~a|c|d);
endmodule

module h4_block(a, b, c, d,h4);
    input a; //select 0
    input b; //select 1
    input c; //select signal
    input d;
	 output h4;
		assign h4 = (b | d) & (~c | d) & (~a|~c) & (~a|~b);
endmodule

module h5_block(a, b, c, d,h5);
    input a; //select 0
    input b; //select 1
    input c; //select signal
    input d;
	 output h5;
		assign h5 = (c | d) & (~b | d) & (~a|b) & (~a|~c) & (a|~b|c);
endmodule

module h6_block(a, b, c, d,h6);
    input a; //select 0
    input b; //select 1
    input c; //select signal
    input d;
	 output h6;
		assign h6 = (b | ~c) & (~c | d) & (~a| b) & (~a|~d) & (a|~b|c) ;
endmodule
