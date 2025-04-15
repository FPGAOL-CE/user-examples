`timescale 1ns / 1ps
 
module top(
	input clk,
	output [1:0]led,
    input [2:0]btn
    );
	reg [31:0]cnt = 0;
	always @ (posedge clk) begin
        cnt <= cnt + 1;
	end
    assign led[0] = cnt[24];
    assign led[1] = ^btn;
endmodule

