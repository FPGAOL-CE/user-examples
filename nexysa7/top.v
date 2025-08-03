module top (
    input wire CLK,           // 100MHz clock from board
    input wire CPU_RESETN,    // CPU reset button (active low)
    output wire [15:0] LED    // 16 LEDs on the board
);

    // Instantiate the blinky module
    blinky blinky_inst (
        .clk(CLK),
        .rst_n(CPU_RESETN),
        .led(LED[0])          // Use the first LED
    );
    
    // Set all other LEDs to off
    assign LED[15:1] = 15'b0;

endmodule 

module blinky (
    input wire clk,           // 100MHz clock input
    input wire rst_n,         // Active low reset
    output reg led            // LED output
);

    // Counter for creating a delay
    reg [25:0] counter;
    
    // Clock divider: 100MHz / 2^26 = ~1.5Hz blink rate
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 26'd0;
            led <= 1'b0;
        end else begin
            counter <= counter + 1'b1;
            if (counter == 26'h3FFFFFF) begin  // When counter reaches max value
                led <= ~led;                   // Toggle LED
                counter <= 26'd0;              // Reset counter
            end
        end
    end

endmodule 
