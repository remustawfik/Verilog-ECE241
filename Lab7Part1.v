module Lab7Part1(SW,HEX0,HEX4,HEX5,HEX2,KEY);

input [9:0] SW;
input [6:0] KEY;
output [6:0] HEX0;
output [6:0] HEX2;
output [6:0] HEX4;
output [6:0] HEX5;

wire [4:0] Address;
wire [3:0] data;
wire [3:0]Q;
wire writeEn;
assign Address = SW[8:4];
assign data = SW[3:0];
assign writeEn = SW[9];


ram32x4 Memory(Address,~KEY[0],data,writeEn,Q);
	
hex_decoder block0(Q,HEX0);
hex_decoder block1(data,HEX2);
hex_decoder block2(Address[3:0],HEX4);
hex_decoder block3(Address[4],HEX5);


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
