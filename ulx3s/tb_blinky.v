`timescale 1ns / 1ps

module tb_blinky();
    // Testbench signals
    reg clk_25mhz;
    reg [6:0] btn;
    wire [7:0] led;
    wire wifi_gpio0;
    
    // Instantiate the module under test
    top dut(
        .clk_25mhz(clk_25mhz),
        .btn(btn),
        .led(led),
        .wifi_gpio0(wifi_gpio0)
    );
    
    // Clock generation (25MHz = 40ns period)
    initial begin
        clk_25mhz = 0;
        forever #20 clk_25mhz = ~clk_25mhz;
    end
    
    // Test stimulus
    initial begin
        // Initialize inputs
        btn = 7'b0000000;
        
        // Wait for a few clock cycles
        #1000;
        
        // Test different button combinations
        btn = 7'b0000001;
        #1000000; // Wait to observe LED behavior
        
        btn = 7'b0000010;
        #1000000;
        
        btn = 7'b0000100;
        #1000000;
        
        btn = 7'b0001000;
        #1000000;
        
        btn = 7'b0010000;
        #1000000;
        
        btn = 7'b0100000;
        #1000000;
        
        btn = 7'b1000000;
        #1000000;
        
        // Test multiple buttons pressed
        btn = 7'b1111111;
        #1000000;
        
        // Back to no buttons
        btn = 7'b0000000;
        #1000000;
        
        // End simulation
        $display("Testbench completed");
        $finish;
    end
    
    // Monitor outputs
    initial begin
        $monitor("Time=%0t clk_25mhz=%b btn=%b led=%b wifi_gpio0=%b", 
                 $time, clk_25mhz, btn, led, wifi_gpio0);
    end
    
    // Optional: Create a VCD file for waveform viewing
    initial begin
        $dumpfile("tb_blinky.vcd");
        $dumpvars(0, tb_blinky);
    end
    
endmodule 