`timescale 1ns / 1ps

module top(
	input clk,
	input [15:0] sw,
	input [3:0] btn,
	output [15:0] led,
	output [2:0] RGB0,
	output [2:0] RGB1
);
	reg [31:0] counter = 0;
	always @(posedge clk) begin
		counter <= counter + 1;
	end

	assign led = sw;
	wire blink0 = counter[23];
	wire blink1 = counter[25];
	wire [2:0] btn_rgb = {btn[2], btn[1], btn[0]};
	assign RGB0 = {3{blink0}} & btn_rgb;
	assign RGB1 = {3{blink1}} & btn_rgb;

endmodule 