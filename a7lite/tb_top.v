`timescale 1ns / 1ps

module tb_top();
    // Testbench signals
    reg clk;
    reg [2:0] btn;
    wire [1:0] led;
    
    // Instantiate the module under test
    top dut(
        .clk(clk),
        .led(led),
        .btn(btn)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Test stimulus
    initial begin
        // Initialize inputs
        btn = 3'b000;
        
        // Wait for a few clock cycles
        #100;
        
        // Test different button combinations
        btn = 3'b001;
        #1000;
        
        btn = 3'b010;
        #1000;
        
        btn = 3'b100;
        #1000;
        
        btn = 3'b111;
        #1000;
        
        btn = 3'b101;
        #1000;
        
        btn = 3'b000;
        #1000;
        
        // End simulation
        $display("Testbench completed");
        $finish;
    end
    
    // Monitor outputs
    initial begin
        $monitor("Time=%0t clk=%b btn=%b led=%b", $time, clk, btn, led);
    end
    
endmodule 