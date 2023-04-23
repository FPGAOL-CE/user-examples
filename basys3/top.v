// Basys3 test
// by petergu 2023.4.23
`timescale 1ns / 1ps
 
module top(
	input CLK100MHZ,
	output [15:0]LED,
	input [15:0]sw
    );
	reg [31:0]cnt = 0;
	always @ (posedge CLK100MHZ) begin
		cnt <= cnt + 1;
	end
	assign LED[7:0] = cnt[31:24];
	assign LED[15:8] = sw[15:8];
endmodule

