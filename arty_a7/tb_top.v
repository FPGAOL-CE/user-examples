`timescale 1ns / 1ps

module tb_top();
    reg clk;
    wire led;

    blinky dut(
        .clk(clk),
        .led(led)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100 MHz
    end

    initial begin
        // run for some time to see a few LED toggles
        #100000;
        $display("Testbench completed");
        $finish;
    end

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_top);
        $monitor("t=%0t clk=%b led=%b", $time, clk, led);
    end

endmodule 