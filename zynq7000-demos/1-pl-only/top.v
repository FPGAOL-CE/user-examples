`timescale 1ns / 1ps
 
module top(
	input clk,
	output [3:0]led,
	input [1:0]sw
    );

	reg [31:0]cnt = 0;
	always @ (posedge clk) begin
		cnt <= cnt + 1;
	end
	assign led[3:2] = cnt[28:27];
	assign led[1:0] = sw[1:0];
endmodule

