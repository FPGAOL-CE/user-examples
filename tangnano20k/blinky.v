module top
(
    input clk,
    input [1:0]key,
    output reg [5:0] led
);
    wire xkey = ^key;

    // PWM signals
    reg [9:0] pwm_counter = 0;  // 10-bit PWM counter (0–1023)
    reg [9:0] brightness = 0;   // 10-bit brightness level
    reg direction = 0;          // 0 = increasing, 1 = decreasing

    // Blinky counter
    reg [31:0] counter = 0;
    always @ (posedge clk) begin
        counter <= counter + 1;
    end

    // Breathing rate controller
    reg [19:0] breath_counter = 0;
    wire breath_tick = (breath_counter == 20'd300_000); // ~100 Hz update at 50 MHz

    // Increment breath counter
    always @(posedge clk) begin
        if (breath_tick)
            breath_counter <= 0;
        else
            breath_counter <= breath_counter + 1;
    end

    // Animate brightness up and down
    always @(posedge clk) begin
        if (breath_tick) begin
            if (!direction)
                brightness <= brightness + 10; // increase brightness
            else
                brightness <= brightness - 10; // decrease brightness

            // Change direction at limits
            if (brightness >= 10'd1010)
                direction <= 1;
            else if (brightness <= 10'd10)
                direction <= 0;
        end
    end

    always @(posedge clk)
        pwm_counter <= pwm_counter + 1;

    wire breath_on = pwm_counter < brightness;

    // PWM output to LEDs
    always @(posedge clk) begin
        if (xkey) 
            led <= {4{breath_on, !breath_on}};
        else
            led <= {4{counter[24], !counter[24]}};
    end

endmodule

