module Trial1(HEX0, SW, CLOCK_50);

	input CLOCK_50;
	input [9:0] SW;
	output [6:0] HEX0;

	wire Enable;
	wire clear1;
	wire reset;

	reg [27:0] count1;

	reg [3:0] count2;

	wire [1:0] select;
	wire [27:0] maxCount;

	assign select = SW[1:0];
	assign reset = SW[9];

	mux4to1 m0(
		.s(select),
		.f(maxCount)
	);
		
	hexdis h0(
		.c0(count2[0]),
		.c1(count2[1]),
		.c2(count2[2]),
		.c3(count2[3]),
		.h0(HEX0[0]),
		.h1(HEX0[1]),
		.h2(HEX0[2]),
		.h3(HEX0[3]),
		.h4(HEX0[4]),
		.h5(HEX0[5]),
		.h6(HEX0[6])
	 );
		
always@(posedge CLOCK_50)
begin
	if((clear1 == 1'b1)|(reset == 1'b1))
		count1 <= 28'd0;
	else
		count1 <= count1 + 1'b1;
end

assign clear1 = Enable;
assign Enable = (count1 == maxCount) ? 1'b1 : 1'b0;

always@(posedge CLOCK_50)
begin
	if(reset == 1'b1)
		count2 <= 4'b0000;
	else if(Enable == 1'b1)
		count2 <= count2 + 1'b1;
	else
		count2 <= count2;
end


endmodule


module mux4to1(s,f);
	input [1:0] s;
	output [27:0] f;
	wire [27:0] w1;
	wire [27:0] w2; //wires connect 2to1 muxes
	
	mux2to1 m3(w1,w2,s[1],f);
	mux2to1 m2(28'd100000000,28'd200000000,s[0],w2);
	mux2to1 m1(28'd1,28'd50000000,s[0],w1);
	
endmodule

module mux2to1(x, y, s, m);
    input [27:0] x; //select 0
    input [27:0] y; //select 1
    input s; //select signal
    output [27:0] m; //output
  
    //assign m = s & y | ~s & x;
    // OR
    assign m = s ? y : x;

endmodule

module hexdis(c0,c1,c2,c3,h0,h1,h2,h3,h4,h5,h6);
	
	//define inputs and outputs
	input c0,c1,c2,c3;
	output h0,h1,h2,h3,h4,h5,h6;
	
	//assign SOP form derived from truth table
	
	assign h0 = (~c3&~c2&~c1&c0)|(~c3&c2&~c1&~c0)|(c3&~c2&c1&c0)|(c3&c2&~c1&c0);
	assign h1 = (~c3&c2&~c1&c0)|(~c3&c2&c1&~c0)|(c3&~c2&c1&c0)|(c3&c2&~c1&~c0)|(c3&c2&c1&~c0)|(c3&c2&c1&c0);
	assign h2 = (~c3&~c2&c1&~c0)|(c3&c2&~c1&~c0)|(c3&c2&c1&~c0)|(c3&c2&c1&c0);
	assign h3 = (~c3&~c2&~c1&c0)|(~c3&c2&~c1&~c0)|(~c3&c2&c1&c0)|(c3&~c2&~c1&c0)|(c3&~c2&c1&~c0)|(c3&c2&c1&c0);
	assign h4 = (~c3&~c2&~c1&c0)|(~c3&~c2&c1&c0)|(~c3&c2&~c1&~c0)|(~c3&c2&~c1&c0)|(~c3&c2&c1&c0)|(c3&~c2&~c1&c0);
	assign h5 = (~c3&~c2&~c1&c0)|(~c3&~c2&c1&~c0)|(~c3&~c2&c1&c0)|(~c3&c2&c1&c0)|(c3&c2&~c1&c0);
	assign h6 = (~c3&~c2&~c1&~c0)|(~c3&~c2&~c1&c0)|(~c3&c2&c1&c0)|(c3&c2&~c1&~c0);
		
endmodule
