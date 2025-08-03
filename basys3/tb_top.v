`timescale 1ns / 1ps

module tb_top();
    // Testbench signals
    reg CLK100MHZ;
    reg [15:0] sw;
    wire [15:0] LED;
    
    // Instantiate the module under test
    top dut(
        .CLK100MHZ(CLK100MHZ),
        .LED(LED),
        .sw(sw)
    );
    
    // Clock generation (100MHz = 10ns period)
    initial begin
        CLK100MHZ = 0;
        forever #5 CLK100MHZ = ~CLK100MHZ;
    end
    
    // Test stimulus
    initial begin
        // Initialize inputs
        sw = 16'h0000;
        
        // Wait for a few clock cycles
        #100;
        
        // Test with different switch values
        sw = 16'hA5A5;
        #1000;
        
        sw = 16'h5A5A;
        #1000;
        
        sw = 16'hFFFF;
        #1000;
        
        sw = 16'h0000;
        #1000;
        
        // End simulation
        $display("Testbench completed");
        $finish;
    end
    
    // Monitor outputs
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_top);
        $monitor("Time=%0t CLK100MHZ=%b sw=%h LED=%h", $time, CLK100MHZ, sw, LED);
    end
    
endmodule 