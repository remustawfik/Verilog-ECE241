
module Lab6Part3(SW,HEX0,HEX2,HEX4,HEX5,KEY,LEDR,CLOCK_50);
    input [9:0] SW;
    input [3:0] KEY;
    input CLOCK_50;
    output [9:0] LEDR;
    output [6:0] HEX0, HEX2,HEX4,HEX5;
	 
	 wire resetM;
	 wire go;
	 wire [7:0] DATAIN;
	 wire [3:0] DDOUT;
	 wire [4:0] DVOUT;
	 wire [4:0] AOUT;
	 
	 assign go = ~KEY[1];
    assign resetM = KEY[0];
	 assign DATAIN = SW[7:0];

	 
	 Part3 workworkworkworkworkwork(
		.clkn(CLOCK_50),
		.resetn(resetM), 
		.gon(go),
		.data_in(DATAIN),
		.DD_out(DDOUT),
		.DV_out(DVOUT),
		.A_out(AOUT)	 
	 );
	 
	 hex_decoder pls(
		.hex_digit(DDOUT), 
		.segments(HEX2)
					);
					
	 hex_decoder pls2(
		.hex_digit(DVOUT), 
		.segments(HEX0)
					);	 

endmodule 

//-----------------------------------------------------------------------------------
module Part3(clkn,resetn, gon,data_in,DD_out,DV_out,A_out);

input clkn,resetn,gon;
input [7:0] data_in;
output [3:0] DD_out;
output [4:0] DV_out, A_out;

wire ldDDn, ldDVn,ldComparen, ldShiftn, ldALUn;
wire ld_alu_out;
wire alu_op;

control doggo (
					.clk(clkn),
					.reset(resetn),
					.go(gon),
					.loadDD(ldDDn),
					.loadDV(ldDVn),
					.loadCompare(ldComparen),
					.loadShift(ldShiftn),
					.loadALU(ld_alu_out),
					.aluSel(alu_op)
					);
					
dataPath pupper (
					.clk(clkn),
					.reset(resetn),
					.go(gon),
					.ldDD(ldDDn),
					.ldDV(ldDVn),
					.ldShift(ldShiftn),
					.ldCompare(ldComparen),
					.ldALU(ld_alu_out),
					.dataIn(data_in),
					.DDout(DD_out),
					.aluOP(alu_op),
					.DVout(DV_out),
					.Aout(A_out)
					);

endmodule 

//-----------------------------------------------------------------------------------

module control(clk,reset,go,loadDD,loadDV,loadCompare,loadShift,loadALU,aluSel);

input clk,reset,go;
//wire temp,q0,muxSel;
output reg loadDD,loadDV,loadCompare,loadShift,loadALU,aluSel;

reg [5:0] current_state, next_state,alu_Out; 

localparam LOAD = 5'd0,
			  LOAD_WAIT = 5'd1,
			  CYCLE_0 = 5'd2,		  
			  CYCLE_1 = 5'd3,	
			  CYCLE_2 = 5'd4,	
			  CYCLE_3 = 5'd5;
			  
always@(*)
	begin : statetable

	case(current_state)
	 LOAD: next_state = go ? LOAD_WAIT : LOAD;
	 LOAD_WAIT: next_state = go ? LOAD_WAIT : CYCLE_0;
	 CYCLE_0: next_state = CYCLE_1;
	 CYCLE_1: next_state = CYCLE_2;
	 CYCLE_2: next_state = CYCLE_3;
	 CYCLE_3: next_state = CYCLE_4;
	 CYCLE_4:  next_state = LOAD;
	 
	 default: next_state = LOAD;
	endcase
	end
	
always@(*)
begin: enable_signals

loadDD = 1'b0;
loadDV = 1'b0;
loadCompare = 1'b0;
loadShift = 1'b0;
loadALU = 1'b0;
aluSel = 1'b0;

case(current_state)
	
	LOAD: begin
	loadDD = 1'b1;
	loadDV = 1'b1;
	loadCompare = 1'b0;
	loadShift = 1'b0;
	loadALU = 1'b0;
	aluSel = 1'b0;
	end
	
	CYCLE_0: begin // Do Shift
	loadDD = 1'b1;
	loadDV = 1'b0;
	loadCompare = 1'b0;
	loadShift = 1'b1;
	loadALU = 1'b0;
	aluSel = 1'b0;
	end
	
	CYCLE_1: begin //Do Subtraction
	loadDD = 1'b0;
	loadDV = 1'b0;
	loadCompare = 1'b0;
	loadShift = 1'b0;
	loadALU = 1'b1;
	aluSel = 1'b1;
	end
	
	CYCLE_2: begin //Do Compare
	loadDD = 1'b0;
	loadDV = 1'b0;
	loadCompare = 1'b1;
	loadShift = 1'b0;
	loadALU = 1'b0;
	aluSel = 1'b0;
	end
	
	CYCLE_3: begin //Do Add
	loadDD = 1'b0;
	loadDV = 1'b0;
	loadCompare = 1'b0;
	loadShift = 1'b0;
	loadALU = 1'b1;
	aluSel = 1'b0;
	end
	
	CYCLE_4: begin //Do output
	loadDD = 1'b0;
	loadDV = 1'b0;
	loadCompare = 1'b0;
	loadShift = 1'b0;
	loadALU = 1'b0;
	aluSel = 1'b0;
	end	
	
endcase
end
	
	
 always@(posedge clk)
    begin: state_FFs
        if(!reset)
            current_state <= LOAD;
        else
            current_state <= next_state;
    end // state_FFS
endmodule


//-----------------------------------------------------------------------------------

module dataPath(clk,reset,go,ldDD,ldDV,ldShift,ldCompare,ldALU,dataIn,DDout, aluOP,DVout,Aout);

	input clk,reset,go,ldDD,ldDV,ldShift,ldCompare,ldALU, aluOP;
	input [7:0] dataIn;
	output [3:0] DDout;
	output [4:0] DVout;
	output [4:0] Aout;
	
	
	
	reg [4:0]RegA,RegDV;
	reg [3:0] RegDD;
	reg [4:0] ALU_out;
	reg [3:0] shiftResultDD;
	reg [4:0] shiftResultA;
	wire temp,Q0;
	wire check = 1'b0;
	wire [3:0] tempDD, 
	
	assign tempDD = dataIn [7:4];

// loading functionality 
 always@(posedge clk) begin
        
		  if(!resetn) begin
            RegA <= 5'b0; 
            RegDV <= 5'b0; 
            RegDD <= 4'b0; 
				ALU_out <= 5'b0;
				shiftResultA  <= 5'b0;
				shiftResultDD <= 4'b0;
	
        end
        else begin
            if(ldALU)
                RegA <= ldShift ? shiftResultA : ALU_out; 
            if(ldDD)
                RegDD <= ldShift ? shiftResultDD : tempDD; 
            if(ld_x)
                RegDV <= {0,dataIn[3:0]}; 
           
        end
    end		

// shifting module 	
 always @(*) 	
	begin: Shift
		if(ldShift)
		begin
		temp = REGDD[3];
		RegA = RegA << 1;
		RegDD = RegDD << 1;
		end
	end

	
//ALU function 	
 always @(*)
    begin : ALU
        // alu
        if(aluOP & !ldCompare)
				begin
					ALU_out = RegA - RegDV; //performs subtraction
					Q0 = ~ALU_out[4];
					if(~Q0) begin
					
					check = 1'b1;
					
					end 
				end
		  if(!aluOP & ldCompare & check)
				begin
					ALU_out = RegA + RegDV; //performs addition
				end
				
			if(!aluOP & ldCompare & !check)
				begin
					ALU_out = RegA + 5'b00000; //performs addition
				end
				
			else begin
			ALU_out = RegA;
			end
			
 end
 
 assign DDout = {RegDD[3:1],Q0};
 assign tempDD = DDout;
 assign DVout = RegDV;
 assign Aout = RegA;

endmodule

//-----------------------------------------------------------------------------------
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
