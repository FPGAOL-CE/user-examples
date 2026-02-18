module top
(
    input clk,          // 27 MHz oscillator
    input [1:0] key,    // active-low push buttons (0 = pressed)
    output reg [5:0] led // active-low LEDs (0 = on)
);
    wire xkey = ^key;   // high when exactly one button is pressed

    // PWM signals for breathing effect
    reg [9:0] pwm_counter = 0;
    reg [9:0] brightness = 0;
    reg direction = 0;  // 0 = increasing, 1 = decreasing

    // Blinky counter
    reg [31:0] counter = 0;
    always @(posedge clk) begin
        counter <= counter + 1;
    end

    // Breathing rate controller (~90 Hz tick at 27 MHz)
    reg [19:0] breath_counter = 0;
    wire breath_tick = (breath_counter == 20'd300_000);

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
                brightness <= brightness + 10;
            else
                brightness <= brightness - 10;

            if (brightness >= 10'd1010)
                direction <= 1;
            else if (brightness <= 10'd10)
                direction <= 0;
        end
    end

    always @(posedge clk)
        pwm_counter <= pwm_counter + 1;

    wire breath_on = pwm_counter < brightness;

    // LEDs are active-low: invert output so 0 = LED on.
    // counter[23] toggles at ~0.8 Hz (visible blink at 27 MHz).
    always @(posedge clk) begin
        if (xkey)
            led <= ~{3{breath_on, !breath_on}};         // breathing mode
        else
            led <= ~{3{counter[23], !counter[23]}};     // blink mode
    end

endmodule
