// FPGAOL tests
// by petergu 2022.3.8 
`timescale 1ns / 1ps
 
module top(
	input clk,
	output [7:0]led,
	input [7:0]sw,
	output uart_tx0,
	input uart_rx0,
	input uart_rts0,
	output uart_cts0,
	output reg [2:0]hexplay0_an = 0,
	output [3:0]hexplay0_d
    );
	reg [31:0]hexplay_cnt = 0;
	always @ (posedge clk) begin
		hexplay_cnt <= hexplay_cnt >= (10000000 / 8) ? 0 : hexplay_cnt + 1;
		if (hexplay_cnt == 0) begin
			hexplay0_an <= hexplay0_an == 7 ? 0 : hexplay0_an + 1;
		end
	end
	assign hexplay0_d = hexplay0_an[0] ? sw[7:4] : sw[3:0];
    assign uart_tx0 = uart_rx0;
	assign uart_cts0 = 0;
	assign led = sw;
endmodule

