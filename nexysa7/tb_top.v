`timescale 1ns / 1ps

module tb_top;
    // Testbench signals
    reg CLK;
    reg CPU_RESETN;
    wire [15:0] LED;
    
    // Instantiate the top module
    top uut (
        .CLK(CLK),
        .CPU_RESETN(CPU_RESETN),
        .LED(LED)
    );
    
    // Clock generation (100MHz = 10ns period)
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK;  // 10ns period = 5ns half period
    end
    
    // Test stimulus
    initial begin
        // Initialize signals
        CPU_RESETN = 0;
        
        // Wait a few clock cycles
        #100;
        
        // Release reset
        CPU_RESETN = 1;
        
        // Run simulation for a longer time to see LED toggle
        #1000000;  // 1ms simulation time
        
        // End simulation
        $display("Simulation completed");
        $finish;
    end
    
    // Monitor LED changes
    always @(LED[0]) begin
        $display("Time: %0t, LED[0] = %b", $time, LED[0]);
    end
    
    // Create VCD file for waveform viewing
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_top);
    end
    
    // Optional: Add a timeout to prevent infinite simulation
    initial begin
        #10000000;  // 10ms timeout
        $display("Simulation timeout reached");
        $finish;
    end

endmodule 