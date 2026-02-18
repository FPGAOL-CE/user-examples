`timescale 1ns / 1ps

module tb_blinky();
    // Testbench signals
    reg clk;
    reg [1:0] key;
    wire [5:0] led;

    // Instantiate the module under test
    top dut(
        .clk(clk),
        .key(key),
        .led(led)
    );

    // Clock generation: 27 MHz = ~37 ns period
    initial begin
        clk = 0;
        forever #18.5 clk = ~clk;
    end

    // Test stimulus
    initial begin
        // Initialize: both buttons released (active-low, so logic-high)
        key = 2'b11;

        // Wait for a few cycles
        #1000;

        // Normal blink mode: no button pressed
        key = 2'b11;
        #2000;

        // Breathing mode: press button 0 (active-low -> drive low)
        key = 2'b10;
        #2000;

        // Breathing mode: press button 1
        key = 2'b01;
        #2000;

        // Both pressed -> xkey = 0 -> back to blink mode
        key = 2'b00;
        #2000;

        // Release all buttons
        key = 2'b11;
        #1000;

        $display("Testbench completed");
        $finish;
    end

    // Monitor outputs
    initial begin
        $monitor("Time=%0t clk=%b key=%b led=%b", $time, clk, key, led);
    end

    // VCD waveform dump
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_blinky);
    end

endmodule
