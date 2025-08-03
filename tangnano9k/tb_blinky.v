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
    
    // Clock generation (50MHz = 20ns period)
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end
    
    // Test stimulus
    initial begin
        // Initialize inputs
        key = 2'b00;
        
        // Wait for a few clock cycles
        #1000;
        
        // Test normal mode (key = 00)
        key = 2'b00;
        #1000000; // Wait to observe normal blinking
        
        // Test breathing mode (key = 01)
        key = 2'b01;
        #1000000; // Wait to observe breathing effect
        
        // Test breathing mode (key = 10)
        key = 2'b10;
        #1000000; // Wait to observe breathing effect
        
        // Test breathing mode (key = 11)
        key = 2'b11;
        #1000000; // Wait to observe breathing effect
        
        // Back to normal mode
        key = 2'b00;
        #1000000;
        
        // End simulation
        $display("Testbench completed");
        $finish;
    end
    
    // Monitor outputs
    initial begin
        $monitor("Time=%0t clk=%b key=%b led=%b", $time, clk, key, led);
    end
    
    // Optional: Create a VCD file for waveform viewing
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_blinky);
    end
    
endmodule 