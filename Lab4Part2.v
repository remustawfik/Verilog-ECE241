`timescale 1ns / 1ns 


module Lab4Part2(LEDR, SW,KEY,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5);
   
	 input [9:0] SW;
	 input [3:0] KEY;
	 output [6:0] HEX0,HEX1,HEX2,HEX3,HEX4,HEX5;
    output [9:0] LEDR;
	 
	 wire [3:0] A;
	 wire [3:0] B;
	 wire [2:0] ALUinput;
	 wire [4:0] Adder_Result;
	 wire [2:0] zero;
	 wire Cin;
	 wire Clock;
	 wire reset_b;
	 wire [7:0] q_ate_bit;
    reg [7:0] ALUout;
	 
    assign Clock = KEY[0];
	 assign A = SW[3:0];
	 assign cin = SW[8];
	 assign reset_b = SW[9];
	 assign LEDR[7:0] = ALUout;
	 assign HEX1[6:0] = 7'b1000000;
	 assign HEX2[6:0] = 7'b1000000;
	 assign HEX3[6:0] = 7'b1000000;
	 assign ALUinput = KEY[3:1];
	 assign zero = 3'b000;
	 

	 
	 HEX_NUM PUPPER0 (
						.a(A[3]),
						.b(A[2]),
						.c(A[1]),
						.d(A[0]),
						.H0(HEX0[0]),
						.H1(HEX0[1]),
						.H2(HEX0[2]),
						.H3(HEX0[3]),
						.H4(HEX0[4]),
						.H5(HEX0[5]),
						.H6(HEX0[6]),
						
						);
						
	HEX_NUM PUPPER4 (
						.a(q_ate_bit[3]),
						.b(q_ate_bit[2]),
						.c(q_ate_bit[1]),
						.d(q_ate_bit[0]),
						.H0(HEX4[0]),
						.H1(HEX4[1]),
						.H2(HEX4[2]),
						.H3(HEX4[3]),
						.H4(HEX4[4]),
						.H5(HEX4[5]),
						.H6(HEX4[6]),
						
						);
						
						
	HEX_NUM PUPPER5 (
						.a(q_ate_bit[7]),
						.b(q_ate_bit[6]),
						.c(q_ate_bit[5]),
						.d(q_ate_bit[4]),
						.H0(HEX5[0]),
						.H1(HEX5[1]),
						.H2(HEX5[2]),
						.H3(HEX5[3]),
						.H4(HEX5[4]),
						.H5(HEX5[5]),
						.H6(HEX5[6]),
						
						);
	four_bit_adder doge(
								.cin(Cin),
								.a0(A[0]),
								.b0(B[0]),
								.a1(A[1]),
								.b1(B[1]),
								.a2(A[2]),
								.b2(B[2]),
								.a3(A[3]),
								.b3(B[3]),
								.s0(Adder_Result[0]),
								.s1(Adder_Result[1]),
								.s2(Adder_Result[2]),
								.s3(Adder_Result[3]),
								.cout(Adder_Result[4])
								
								);
	

synch_set_register smol(
								.d(ALUout),
								.Clock(~Clock),
								.Reset_b(reset_b),
								.q(q_ate_bit),
								
								
								);
								
	assign B = q_ate_bit[3:0]; 							

								
always@(*)
	begin
	case(~ALUinput)
	3'b000: ALUout = {zero, Adder_Result}; //works
	3'b001: ALUout = A+B;//wtf
	3'b010: ALUout = ({A,B})? 8'b01111110 : 8'b00000000; //works
	3'b101: ALUout = {(A^B),(A|B)}; //works
	3'b011: ALUout = (|{A,B})? 8'b10000001 : 8'b00000000; //works
	3'b100: ALUout = {A,B<<A}; 
	3'b110: ALUout = A*B;
	3'b111: ALUout = q_ate_bit; 
	default: ALUout = 8'b00000000;
	endcase
	end
	
	
	
endmodule


module synch_set_register(d,Clock,Reset_b,q);
	input [7:0] d;
	input Clock;
	input Reset_b;
	output reg [7:0] q;

	
	always @(posedge Clock) // triggered every time clock rises
	begin
	
		if (Reset_b == 1'b0)
			begin			// when Reset b is 0 (note this is tested on every rising clock edge)
			q <= 8'b0;
			
			end        // q is set to 0. Note that the assignment uses <=
		else          // when Reset b is not 0
			begin	
			q <= d;
		   	// value of d passes through to output q
			end

		
	end
   
endmodule 

	
module four_bit_adder(cin,a0,b0,a1,b1,a2,b2,a3,b3,s0,s1,s2,s3,cout);
	input cin,a0,b0,a1,b1,a2,b2,a3,b3;
	output s0,s1,s2,s3,cout;
	wire c1,c2,c3;
	
	full_adder FA1(a0,b0,cin,s0,c1);
	full_adder FA2(a1,b1,c1,s1,c2);
	full_adder FA3(a2,b2,c2,s2,c3);
	full_adder FA4(a3,b3,c3,s3,cout);
	

endmodule

module full_adder(a,b,ci,s,co);
	input a,b,ci;
	output s,co;
	wire w1;
	
	assign w1 = a ^ b;
	assign s = ci ^ w1;
	
	mux2to1 cat (b,ci,w1,co);
	
endmodule
	

module mux2to1(x,y,s,m);
   input x,y,s;
	output m;
   assign m = s ? y : x;

endmodule 

//Hex functionality
module HEX_NUM(a,b,c,d, H0,H1,H2,H3,H4,H5,H6);

	input a,b,c,d;
	output H0,H1,H2,H3,H4,H5,H6;
	
   h0_block DOGGO0(a, b, c, d,H0);
   h1_block DOGGO1(a, b, c, d,H1);
   h2_block DOGGO2(a, b, c, d,H2);
   h3_block DOGGO3(a, b, c, d,H3);
   h4_block DOGGO4(a, b, c, d,H4);
   h5_block DOGGO5(a, b, c, d,H5);
	h6_block DOGGO6(a, b, c, d,H6);
	
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