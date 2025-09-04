`timescale 1ns / 1ps

module tb_top();
	reg clk;
	reg [15:0] sw;
	reg [3:0] btn;
	wire [15:0] led;
	wire [2:0] RGB0;
	wire [2:0] RGB1;

	top dut(
		.clk(clk),
		.sw(sw),
		.btn(btn),
		.led(led),
		.RGB0(RGB0),
		.RGB1(RGB1)
	);

	initial begin
		clk = 0;
		forever #5 clk = ~clk; // 100 MHz
	end

	initial begin
		sw = 16'h0000;
		btn = 4'b0000;
		#100;

		sw = 16'hA5A5; #1000;
		sw = 16'h5A5A; #1000;
		sw = 16'hFFFF; #1000;
		sw = 16'h0000; #1000;

		btn = 4'b001; #2000;
		btn = 4'b010; #2000;
		btn = 4'b100; #2000;
		btn = 4'b000; #1000;

		$display("Testbench completed");
		$finish;
	end

	initial begin
		$dumpfile("wave.vcd");
		$dumpvars(0, tb_top);
		$monitor("t=%0t clk=%b sw=%h btn=%b led=%h RGB0=%b RGB1=%b", $time, clk, sw, btn, led, RGB0, RGB1);
	end

endmodule 