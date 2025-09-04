`timescale 1ns / 1ps

module tb_pwm();
    // Testbench signals
    reg CLK;
    wire LEDR_N;
    wire LEDG_N;
    wire P1A7;
    wire P1A8;
    
    // Instantiate the module under test
    top dut(
        .CLK(CLK),
        .LEDR_N(LEDR_N),
        .LEDG_N(LEDG_N),
        .P1A7(P1A7),
        .P1A8(P1A8)
    );
    
    // Clock generation
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK;
    end
    
    // Test stimulus
    initial begin
        // Wait for a few clock cycles to observe PWM behavior
        #10000; // Wait for 1ms to see PWM cycles
        
        // Continue simulation to observe fading behavior
        #100000; // Wait for 10ms
        
        // End simulation
        $display("Testbench completed");
        $finish;
    end
    
    // Monitor outputs
    initial begin
        $monitor("Time=%0t CLK=%b LEDR_N=%b LEDG_N=%b P1A7=%b P1A8=%b", 
                 $time, CLK, LEDR_N, LEDG_N, P1A7, P1A8);
    end
    
    // Optional: Create a VCD file for waveform viewing
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_pwm);
    end
    
endmodule 