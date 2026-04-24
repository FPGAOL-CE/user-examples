/**
 * OV7670 Camera to VGA Display Demo
 * Edge-Artix-7 Board
 *
 * Notes:
 * - The XC7A35T does not have enough BRAM for a full 640x480 color framebuffer.
 * - This design stores a 4-bit framebuffer (640x480) in dual-port block RAM.
 * - On startup the FPGA configures the OV7670 over SCCB for VGA RGB565 output.
 * - The capture path then interprets the camera bus as RGB565 words.
 * References;
 * - OV7670 datasheet: https://www-ug.eecg.toronto.edu/msl/manuals/OV7670Datasheet.pdf
 * - MIT OV7670 setup notes: https://fpga.mit.edu/6205/F23/documentation/ov7670
 * Helped by codex gpt-5.4
 */

module ov7670_vga_demo (
    input clk,                  // 50 MHz input clock
    input [15:0]sw,
    input [4:0]pb,
    output [15:0]led,
    
    // OV7670 Camera Interface
    output ov7670_xclk,         // Camera external clock (25 MHz)
    input [7:0] ov7670_data,    // 8-bit pixel data from camera
    input ov7670_vsync,         // Frame sync
    input ov7670_href,          // Line sync
    input ov7670_pclk,          // Pixel clock from camera
    output ov7670_reset,        // Reset (active high)
    output ov7670_pwdn,         // Power down (active high)
    
    // OV7670 I2C Configuration (for future use)
    inout ov7670_siod,          // I2C data
    inout ov7670_sioc,          // I2C clock
    
    // VGA Output
    output vga_hsync,           // Horizontal sync
    output vga_vsync,           // Vertical sync
    output [3:0] vga_r,         // Red [3:0]
    output [3:0] vga_g,         // Green [3:0]
    output [3:0] vga_b,         // Blue [3:0]

    // 1.8-inch SPI TFT
    output tft_sck,
    output tft_sdi,
    output tft_dc,
    output tft_reset,
    output tft_cs
);

    localparam H_ACTIVE = 640;
    localparam H_FP     = 16;
    localparam H_SYNC   = 96;
    localparam H_BP     = 48;
    localparam H_TOTAL  = H_ACTIVE + H_FP + H_SYNC + H_BP;

    localparam V_ACTIVE = 480;
    localparam V_FP     = 10;
    localparam V_SYNC   = 2;
    localparam V_BP     = 33;
    localparam V_TOTAL  = V_ACTIVE + V_FP + V_SYNC + V_BP;

    localparam FRAME_PIXELS = H_ACTIVE * V_ACTIVE;
    localparam ADDR_WIDTH   = 19;

    wire clk_25mhz_raw;
    wire clk_25mhz;
    wire mmcm_fb_out;
    wire mmcm_locked;
    wire display_tft = sw[1];
    wire reset_db;

    debounce #(
        .COUNTER_WIDTH(20)
    ) reset_debounce (
        .clk(clk),
        .din(sw[0]),
        .dout(reset_db)
    );

    MMCME2_ADV #(
        .BANDWIDTH("OPTIMIZED"),
        .COMPENSATION("ZHOLD"),
        .CLKIN1_PERIOD(20.0),
        .CLKFBOUT_MULT_F(20.0),
        .CLKOUT0_DIVIDE_F(40.0),
        .DIVCLK_DIVIDE(1),
        .CLKOUT0_PHASE(0.0),
        .STARTUP_WAIT("FALSE")
    ) mmcm_inst (
        .CLKIN1(clk),
        .CLKFBIN(mmcm_fb_out),
        .CLKFBOUT(mmcm_fb_out),
        .CLKOUT0(clk_25mhz_raw),
        .LOCKED(mmcm_locked),
        .PWRDWN(1'b0),
        .RST(reset_db)
    );

    BUFG clk_25mhz_bufg (
        .I(clk_25mhz_raw),
        .O(clk_25mhz)
    );

    assign led = {mmcm_locked, pb, sw[9:0]};

    assign ov7670_xclk  = clk_25mhz;
    assign ov7670_reset = mmcm_locked;
    assign ov7670_pwdn  = 1'b0;

    wire cam_cfg_done;
    wire cam_cfg_busy;
    wire siod_drive_low;
    wire sioc_drive_low;

    assign ov7670_siod = siod_drive_low ? 1'b0 : 1'bz;
    assign ov7670_sioc = sioc_drive_low ? 1'b0 : 1'bz;

    reg [9:0] cam_x = 10'd0;
    reg [8:0] cam_y = 9'd0;
    reg       rgb_byte_phase = 1'b0;
    reg       href_d = 1'b0;
    reg [7:0] rgb_high_byte = 8'd0;

    reg [ADDR_WIDTH-1:0] cam_wr_addr = {ADDR_WIDTH{1'b0}};
    reg                  cam_we = 1'b0;
    reg [3:0]            cam_wr_pixel = 4'd0;

    wire [7:0] rgb565_r = {rgb_high_byte[7:3], 3'b000};
    wire [7:0] rgb565_g = {rgb_high_byte[2:0], ov7670_data[7:5], 2'b00};
    wire [7:0] rgb565_b = {ov7670_data[4:0], 3'b000};
    wire [9:0] rgb565_luma =
        ({2'b00, rgb565_r} >> (3)) +
        ({2'b00, rgb565_g} >> (3)) +
        ({2'b00, rgb565_b} >> 3);
    
    wire [7:4]cam_pixel_sel = sw[15:14] == 2'b00 ? rgb565_r[7:4] :
                                sw[15:14] == 2'b01 ? rgb565_g[7:4] : 
                                sw[15:14] == 2'b10 ? rgb565_b[7:4] :
                                rgb565_luma[5:2];

    always @(posedge ov7670_pclk) begin
        href_d <= ov7670_href;
        cam_we <= 1'b0;

        if (!mmcm_locked || !cam_cfg_done || ov7670_vsync) begin
            cam_x <= 10'd0;
            cam_y <= 9'd0;
            rgb_byte_phase <= 1'b0;
            cam_wr_addr <= {ADDR_WIDTH{1'b0}};
        end else begin
            if (ov7670_href) begin
                if (!rgb_byte_phase) begin
                    rgb_high_byte <= ov7670_data;
                end else begin
                    if (cam_x < H_ACTIVE && cam_y < V_ACTIVE) begin
                        cam_we <= 1'b1;
                        cam_wr_pixel <= cam_pixel_sel;
                        cam_wr_addr <= cam_wr_addr + 1'b1;
                        cam_x <= cam_x + 1'b1;
                    end
                end
                rgb_byte_phase <= ~rgb_byte_phase;
            end else begin
                rgb_byte_phase <= 1'b0;
                if (href_d) begin
                    cam_x <= 10'd0;
                    if (cam_y < (V_ACTIVE - 1))
                        cam_y <= cam_y + 1'b1;
                end
            end
        end
    end

    reg [9:0] vga_x = 10'd0;
    reg [9:0] vga_y = 10'd0;

    always @(posedge clk_25mhz) begin
        if (!mmcm_locked) begin
            vga_x <= 10'd0;
            vga_y <= 10'd0;
        end else if (vga_x == H_TOTAL - 1) begin
            vga_x <= 10'd0;
            if (vga_y == V_TOTAL - 1)
                vga_y <= 10'd0;
            else
                vga_y <= vga_y + 1'b1;
        end else begin
            vga_x <= vga_x + 1'b1;
        end
    end

    assign vga_hsync = ~((vga_x >= (H_ACTIVE + H_FP)) &&
                         (vga_x < (H_ACTIVE + H_FP + H_SYNC)));
    assign vga_vsync = ~((vga_y >= (V_ACTIVE + V_FP)) &&
                         (vga_y < (V_ACTIVE + V_FP + V_SYNC)));

    wire vga_active = (vga_x < H_ACTIVE) && (vga_y < V_ACTIVE);
    wire [ADDR_WIDTH-1:0] vga_linear_addr = (vga_y * H_ACTIVE) + vga_x;

    reg                  vga_active_d = 1'b0;
    wire [3:0]           fb_rd_pixel;
    wire [ADDR_WIDTH-1:0] tft_fb_addr;
    wire [ADDR_WIDTH-1:0] fb_rd_addr = display_tft ? tft_fb_addr :
                                       (vga_active ? vga_linear_addr : {ADDR_WIDTH{1'b0}});
    wire [3:0] tft_debug;

    always @(posedge clk_25mhz) begin
        if (!mmcm_locked) begin
            vga_active_d <= 1'b0;
        end else begin
            vga_active_d <= vga_active;
        end
    end

    frame_buffer_dp_ram #(
        .WIDTH(4),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DEPTH(FRAME_PIXELS)
    ) frame_buffer (
        .wr_clk(ov7670_pclk),
        .wr_en(cam_we),
        .wr_addr(cam_wr_addr),
        .wr_data(cam_wr_pixel),
        .rd_clk(clk_25mhz),
        .rd_addr(fb_rd_addr),
        .rd_data(fb_rd_pixel)
    );

    assign vga_r = (!display_tft && vga_active_d) ? fb_rd_pixel : 4'h0;
    assign vga_g = (!display_tft && vga_active_d) ? fb_rd_pixel : 4'h0;
    assign vga_b = (!display_tft && vga_active_d) ? fb_rd_pixel : 4'h0;

    ov7670_sccb_init camera_init (
        .clk(clk_25mhz),
        .reset(!mmcm_locked),
        .siod_in(ov7670_siod),
        .siod_drive_low(siod_drive_low),
        .sioc_drive_low(sioc_drive_low),
        .busy(cam_cfg_busy),
        .done(cam_cfg_done)
    );

    tft_display_scanout tft_scanout (
        .clk(clk_25mhz),
        .reset(!mmcm_locked),
        .enable(display_tft),
        .fb_pixel(fb_rd_pixel),
        .fb_addr(tft_fb_addr),
        .tft_sck(tft_sck),
        .tft_sdi(tft_sdi),
        .tft_dc(tft_dc),
        .tft_reset(tft_reset),
        .tft_cs(tft_cs),
        .debug(tft_debug)
    );

endmodule

module debounce #(
    parameter COUNTER_WIDTH = 20
) (
    input clk,
    input din,
    output reg dout = 1'b0
);

    reg din_meta = 1'b0;
    reg din_sync = 1'b0;
    reg [COUNTER_WIDTH-1:0] stable_count = {COUNTER_WIDTH{1'b0}};

    always @(posedge clk) begin
        din_meta <= din;
        din_sync <= din_meta;

        if (din_sync == dout) begin
            stable_count <= {COUNTER_WIDTH{1'b0}};
        end else begin
            stable_count <= stable_count + 1'b1;
            if (&stable_count) begin
                dout <= din_sync;
                stable_count <= {COUNTER_WIDTH{1'b0}};
            end
        end
    end

endmodule

module tft_display_scanout (
    input clk,
    input reset,
    input enable,
    input [3:0] fb_pixel,
    output reg [18:0] fb_addr,
    output tft_sck,
    output tft_sdi,
    output tft_dc,
    output tft_reset,
    output tft_cs,
    output [3:0] debug
);

    localparam TFT_W = 128;
    localparam TFT_H = 160;
    localparam SPI_DIV = 2;

    localparam ST_HW_RESET_0   = 6'd0;
    localparam ST_HW_RESET_1   = 6'd1;
    localparam ST_INIT_LOAD    = 6'd2;
    localparam ST_INIT_WAIT    = 6'd3;
    localparam ST_STREAM_PREP  = 6'd4;
    localparam ST_STREAM_REQ   = 6'd5;
    localparam ST_STREAM_LATCH = 6'd6;
    localparam ST_STREAM_HI    = 6'd7;
    localparam ST_STREAM_HI_W  = 6'd8;
    localparam ST_STREAM_LO    = 6'd9;
    localparam ST_STREAM_LO_W  = 6'd10;
    localparam ST_NEXT_PIXEL   = 6'd11;

    localparam INIT_LEN = 18;

    reg [7:0] init_byte [0:INIT_LEN-1];
    reg       init_dc [0:INIT_LEN-1];
    reg [15:0] init_delay [0:INIT_LEN-1];

    initial begin
        init_byte[0] = 8'h01; init_dc[0] = 1'b0; init_delay[0] = 16'd3750;
        init_byte[1] = 8'h11; init_dc[1] = 1'b0; init_delay[1] = 16'd3750;
        init_byte[2] = 8'h3A; init_dc[2] = 1'b0; init_delay[2] = 16'd0;
        init_byte[3] = 8'h05; init_dc[3] = 1'b1; init_delay[3] = 16'd0;
        init_byte[4] = 8'h36; init_dc[4] = 1'b0; init_delay[4] = 16'd0;
        init_byte[5] = 8'hC8; init_dc[5] = 1'b1; init_delay[5] = 16'd0;
        init_byte[6] = 8'h2A; init_dc[6] = 1'b0; init_delay[6] = 16'd0;
        init_byte[7] = 8'h00; init_dc[7] = 1'b1; init_delay[7] = 16'd0;
        init_byte[8] = 8'h00; init_dc[8] = 1'b1; init_delay[8] = 16'd0;
        init_byte[9] = 8'h00; init_dc[9] = 1'b1; init_delay[9] = 16'd0;
        init_byte[10] = 8'h7F; init_dc[10] = 1'b1; init_delay[10] = 16'd0;
        init_byte[11] = 8'h2B; init_dc[11] = 1'b0; init_delay[11] = 16'd0;
        init_byte[12] = 8'h00; init_dc[12] = 1'b1; init_delay[12] = 16'd0;
        init_byte[13] = 8'h00; init_dc[13] = 1'b1; init_delay[13] = 16'd0;
        init_byte[14] = 8'h00; init_dc[14] = 1'b1; init_delay[14] = 16'd0;
        init_byte[15] = 8'h9F; init_dc[15] = 1'b1; init_delay[15] = 16'd0;
        init_byte[16] = 8'h29; init_dc[16] = 1'b0; init_delay[16] = 16'd500;
        init_byte[17] = 8'h2C; init_dc[17] = 1'b0; init_delay[17] = 16'd0;
    end

    reg [5:0] state = ST_HW_RESET_0;
    reg [5:0] init_index = 6'd0;
    reg [15:0] wait_counter = 16'd0;

    reg spi_cs = 1'b1;
    reg spi_dc = 1'b0;
    reg spi_sck = 1'b0;
    reg spi_sdi = 1'b0;
    reg spi_busy = 1'b0;
    reg [7:0] spi_shift = 8'd0;
    reg [2:0] spi_bits = 3'd0;
    reg spi_phase = 1'b0;
    reg [1:0] spi_div = 2'd0;

    reg [7:0] pixel_x = 8'd0;
    reg [7:0] pixel_y = 8'd0;
    reg [7:0] color_hi = 8'd0;
    reg [7:0] color_lo = 8'd0;
    reg tft_reset_r = 1'b0;

    wire [9:0] src_x = {pixel_x, 2'b00} + pixel_x;
    wire [8:0] src_y = {pixel_y, 1'b0} + pixel_y;
    wire [18:0] scaled_addr = ({10'd0, src_y} << 9) + ({10'd0, src_y} << 7) + src_x;

    assign tft_sck = spi_sck;
    assign tft_sdi = spi_sdi;
    assign tft_dc = spi_dc;
    assign tft_cs = spi_cs;
    assign tft_reset = tft_reset_r;
    assign debug = {state[2:0], spi_busy};

    always @(posedge clk) begin
        if (reset) begin
            state <= ST_HW_RESET_0;
            init_index <= 6'd0;
            wait_counter <= 16'd0;
            pixel_x <= 8'd0;
            pixel_y <= 8'd0;
            color_hi <= 8'd0;
            color_lo <= 8'd0;
            fb_addr <= 19'd0;
            tft_reset_r <= 1'b0;
            spi_cs <= 1'b1;
            spi_dc <= 1'b0;
            spi_sck <= 1'b0;
            spi_sdi <= 1'b0;
            spi_busy <= 1'b0;
            spi_shift <= 8'd0;
            spi_bits <= 3'd0;
            spi_phase <= 1'b0;
            spi_div <= 2'd0;
        end else begin
            if (spi_busy) begin
                if (spi_div == SPI_DIV - 1) begin
                    spi_div <= 2'd0;
                    if (!spi_phase) begin
                        spi_sck <= 1'b0;
                        spi_sdi <= spi_shift[7];
                        spi_phase <= 1'b1;
                    end else begin
                        spi_sck <= 1'b1;
                        spi_shift <= {spi_shift[6:0], 1'b0};
                        spi_phase <= 1'b0;
                        if (spi_bits == 3'd0) begin
                            spi_busy <= 1'b0;
                            spi_cs <= 1'b1;
                        end else begin
                            spi_bits <= spi_bits - 1'b1;
                        end
                    end
                end else begin
                    spi_div <= spi_div + 1'b1;
                end
            end else begin
                spi_div <= 2'd0;
                spi_sck <= 1'b0;
                case (state)
                    ST_HW_RESET_0: begin
                        tft_reset_r <= 1'b0;
                        init_index <= 6'd0;
                        fb_addr <= 19'd0;
                        if (wait_counter == 16'd2500) begin
                            wait_counter <= 16'd0;
                            state <= ST_HW_RESET_1;
                        end else begin
                            wait_counter <= wait_counter + 1'b1;
                        end
                    end

                    ST_HW_RESET_1: begin
                        tft_reset_r <= 1'b1;
                        if (wait_counter == 16'd2500) begin
                            wait_counter <= 16'd0;
                            state <= ST_INIT_LOAD;
                        end else begin
                            wait_counter <= wait_counter + 1'b1;
                        end
                    end

                    ST_INIT_LOAD: begin
                        spi_cs <= 1'b0;
                        spi_dc <= init_dc[init_index];
                        spi_shift <= init_byte[init_index];
                        spi_bits <= 3'd7;
                        spi_phase <= 1'b0;
                        spi_busy <= 1'b1;
                        state <= ST_INIT_WAIT;
                    end

                    ST_INIT_WAIT: begin
                        if (init_delay[init_index] != 16'd0) begin
                            if (wait_counter == init_delay[init_index]) begin
                                wait_counter <= 16'd0;
                                if (init_index == INIT_LEN - 1) begin
                                    state <= ST_STREAM_PREP;
                                end else begin
                                    init_index <= init_index + 1'b1;
                                    state <= ST_INIT_LOAD;
                                end
                            end else begin
                                wait_counter <= wait_counter + 1'b1;
                            end
                        end else begin
                            if (init_index == INIT_LEN - 1) begin
                                state <= ST_STREAM_PREP;
                            end else begin
                                init_index <= init_index + 1'b1;
                                state <= ST_INIT_LOAD;
                            end
                        end
                    end

                    ST_STREAM_PREP: begin
                        pixel_x <= 8'd0;
                        pixel_y <= 8'd0;
                        state <= ST_STREAM_REQ;
                    end

                    ST_STREAM_REQ: begin
                        if (enable) begin
                            fb_addr <= scaled_addr;
                            state <= ST_STREAM_LATCH;
                        end
                    end

                    ST_STREAM_LATCH: begin
                        color_hi <= {fb_pixel, fb_pixel[3], fb_pixel[3:1]};
                        color_lo <= {fb_pixel[0], fb_pixel[3:2], fb_pixel, fb_pixel[3]};
                        state <= ST_STREAM_HI;
                    end

                    ST_STREAM_HI: begin
                        spi_cs <= 1'b0;
                        spi_dc <= 1'b1;
                        spi_shift <= color_hi;
                        spi_bits <= 3'd7;
                        spi_phase <= 1'b0;
                        spi_busy <= 1'b1;
                        state <= ST_STREAM_HI_W;
                    end

                    ST_STREAM_HI_W: begin
                        state <= ST_STREAM_LO;
                    end

                    ST_STREAM_LO: begin
                        spi_cs <= 1'b0;
                        spi_dc <= 1'b1;
                        spi_shift <= color_lo;
                        spi_bits <= 3'd7;
                        spi_phase <= 1'b0;
                        spi_busy <= 1'b1;
                        state <= ST_STREAM_LO_W;
                    end

                    ST_STREAM_LO_W: begin
                        state <= ST_NEXT_PIXEL;
                    end

                    ST_NEXT_PIXEL: begin
                        if (pixel_x == TFT_W - 1) begin
                            pixel_x <= 8'd0;
                            if (pixel_y == TFT_H - 1)
                                pixel_y <= 8'd0;
                            else
                                pixel_y <= pixel_y + 1'b1;
                        end else begin
                            pixel_x <= pixel_x + 1'b1;
                        end
                        state <= ST_STREAM_REQ;
                    end

                    default: begin
                        state <= ST_HW_RESET_0;
                    end
                endcase
            end
        end
    end

endmodule

module frame_buffer_dp_ram #(
    parameter WIDTH = 4,
    parameter ADDR_WIDTH = 19,
    parameter DEPTH = 307200
) (
    input wr_clk,
    input wr_en,
    input [ADDR_WIDTH-1:0] wr_addr,
    input [WIDTH-1:0] wr_data,

    input rd_clk,
    input [ADDR_WIDTH-1:0] rd_addr,
    output reg [WIDTH-1:0] rd_data
);

    (* ram_style = "block" *) reg [WIDTH-1:0] mem [0:DEPTH-1];

    always @(posedge wr_clk) begin
        if (wr_en && wr_addr < DEPTH)
            mem[wr_addr] <= wr_data;
    end

    always @(posedge rd_clk) begin
        if (rd_addr < DEPTH)
            rd_data <= mem[rd_addr];
        else
            rd_data <= {WIDTH{1'b0}};
    end

endmodule

/*
  - COM7 (0x12) = 0x04 for RGB output
  - COM15 (0x40) = 0xD0 for RGB565/full range
  - TSLB (0x3A) = 0x04 for byte ordering
  - RGB444 (0x8C) = 0x00 to keep RGB444 disabled
*/
module ov7670_sccb_init (
    input clk,
    input reset,
    input siod_in,
    output siod_drive_low,
    output sioc_drive_low,
    output busy,
    output done
);

    localparam CLK_DIV = 125;
    localparam STARTUP_WAIT_CLKS = 18'd250000;
    localparam POST_RESET_WAIT_CLKS = 18'd250000;
    localparam BETWEEN_WRITES_WAIT_CLKS = 18'd25000;
    localparam ROM_LEN = 10;

    localparam ST_POWERUP_WAIT = 4'd0;
    localparam ST_LOAD_BYTE     = 4'd1;
    localparam ST_START_0       = 4'd2;
    localparam ST_START_1       = 4'd3;
    localparam ST_BIT_SETUP     = 4'd4;
    localparam ST_BIT_HIGH      = 4'd5;
    localparam ST_BIT_LOW       = 4'd6;
    localparam ST_ACK_SETUP     = 4'd7;
    localparam ST_ACK_HIGH      = 4'd8;
    localparam ST_ACK_LOW       = 4'd9;
    localparam ST_STOP_0        = 4'd10;
    localparam ST_STOP_1        = 4'd11;
    localparam ST_STOP_2        = 4'd12;
    localparam ST_WAIT_NEXT     = 4'd13;
    localparam ST_DONE          = 4'd14;

    reg [7:0] rom_addr [0:ROM_LEN-1];
    reg [7:0] rom_data [0:ROM_LEN-1];

    initial begin
        rom_addr[0] = 8'h12; rom_data[0] = 8'h80;
        rom_addr[1] = 8'h12; rom_data[1] = 8'h04;
        rom_addr[2] = 8'h11; rom_data[2] = 8'h80;
        rom_addr[3] = 8'h0C; rom_data[3] = 8'h00;
        rom_addr[4] = 8'h3E; rom_data[4] = 8'h00;
        rom_addr[5] = 8'h04; rom_data[5] = 8'h00;
        rom_addr[6] = 8'h40; rom_data[6] = 8'hD0;
        rom_addr[7] = 8'h3A; rom_data[7] = 8'h04;
        rom_addr[8] = 8'h8C; rom_data[8] = 8'h00;
        rom_addr[9] = 8'hB0; rom_data[9] = 8'h84;
    end

    reg [3:0] state = ST_POWERUP_WAIT;
    reg [7:0] byte_to_send = 8'h00;
    reg [1:0] byte_index = 2'd0;
    reg [2:0] bit_index = 3'd7;
    reg [3:0] rom_index = 4'd0;
    reg [17:0] wait_counter = 18'd0;
    reg scl_low = 1'b0;
    reg sda_low = 1'b0;
    reg [7:0] reg_addr_latched = 8'h00;
    reg [7:0] reg_data_latched = 8'h00;
    reg cfg_done = 1'b0;
    reg cfg_busy = 1'b1;

    reg [7:0] clk_div = 8'd0;
    wire tick = (clk_div == CLK_DIV - 1);

    assign sioc_drive_low = scl_low;
    assign siod_drive_low = sda_low;
    assign busy = cfg_busy;
    assign done = cfg_done;

    always @(posedge clk) begin
        if (reset) begin
            clk_div <= 8'd0;
        end else if (tick) begin
            clk_div <= 8'd0;
        end else begin
            clk_div <= clk_div + 1'b1;
        end
    end

    always @(posedge clk) begin
        if (reset) begin
            state <= ST_POWERUP_WAIT;
            byte_to_send <= 8'h00;
            byte_index <= 2'd0;
            bit_index <= 3'd7;
            rom_index <= 4'd0;
            wait_counter <= 18'd0;
            scl_low <= 1'b0;
            sda_low <= 1'b0;
            reg_addr_latched <= 8'h00;
            reg_data_latched <= 8'h00;
            cfg_done <= 1'b0;
            cfg_busy <= 1'b1;
        end else if (tick) begin
            case (state)
                ST_POWERUP_WAIT: begin
                    scl_low <= 1'b0;
                    sda_low <= 1'b0;
                    cfg_busy <= 1'b1;
                    cfg_done <= 1'b0;
                    if (wait_counter == STARTUP_WAIT_CLKS - 1) begin
                        wait_counter <= 18'd0;
                        state <= ST_LOAD_BYTE;
                    end else begin
                        wait_counter <= wait_counter + 1'b1;
                    end
                end

                ST_LOAD_BYTE: begin
                    reg_addr_latched <= rom_addr[rom_index];
                    reg_data_latched <= rom_data[rom_index];
                    byte_index <= 2'd0;
                    byte_to_send <= 8'h42;
                    bit_index <= 3'd7;
                    state <= ST_START_0;
                end

                ST_START_0: begin
                    scl_low <= 1'b0;
                    sda_low <= 1'b0;
                    state <= ST_START_1;
                end

                ST_START_1: begin
                    scl_low <= 1'b0;
                    sda_low <= 1'b1;
                    state <= ST_BIT_SETUP;
                end

                ST_BIT_SETUP: begin
                    scl_low <= 1'b1;
                    sda_low <= !byte_to_send[bit_index];
                    state <= ST_BIT_HIGH;
                end

                ST_BIT_HIGH: begin
                    scl_low <= 1'b0;
                    state <= ST_BIT_LOW;
                end

                ST_BIT_LOW: begin
                    scl_low <= 1'b1;
                    if (bit_index == 3'd0) begin
                        state <= ST_ACK_SETUP;
                    end else begin
                        bit_index <= bit_index - 1'b1;
                        state <= ST_BIT_SETUP;
                    end
                end

                ST_ACK_SETUP: begin
                    scl_low <= 1'b1;
                    sda_low <= 1'b0;
                    state <= ST_ACK_HIGH;
                end

                ST_ACK_HIGH: begin
                    scl_low <= 1'b0;
                    state <= ST_ACK_LOW;
                end

                ST_ACK_LOW: begin
                    scl_low <= 1'b1;
                    if (byte_index == 2'd0) begin
                        byte_index <= 2'd1;
                        byte_to_send <= reg_addr_latched;
                        bit_index <= 3'd7;
                        state <= ST_BIT_SETUP;
                    end else if (byte_index == 2'd1) begin
                        byte_index <= 2'd2;
                        byte_to_send <= reg_data_latched;
                        bit_index <= 3'd7;
                        state <= ST_BIT_SETUP;
                    end else begin
                        state <= ST_STOP_0;
                    end
                end

                ST_STOP_0: begin
                    scl_low <= 1'b1;
                    sda_low <= 1'b1;
                    state <= ST_STOP_1;
                end

                ST_STOP_1: begin
                    scl_low <= 1'b0;
                    sda_low <= 1'b1;
                    state <= ST_STOP_2;
                end

                ST_STOP_2: begin
                    scl_low <= 1'b0;
                    sda_low <= 1'b0;
                    wait_counter <= 18'd0;
                    state <= ST_WAIT_NEXT;
                end

                ST_WAIT_NEXT: begin
                    scl_low <= 1'b0;
                    sda_low <= 1'b0;
                    if ((rom_index == 4'd0 && wait_counter == POST_RESET_WAIT_CLKS - 1) ||
                        (rom_index != 4'd0 && wait_counter == BETWEEN_WRITES_WAIT_CLKS - 1)) begin
                        wait_counter <= 18'd0;
                        if (rom_index == ROM_LEN - 1) begin
                            state <= ST_DONE;
                        end else begin
                            rom_index <= rom_index + 1'b1;
                            state <= ST_LOAD_BYTE;
                        end
                    end else begin
                        wait_counter <= wait_counter + 1'b1;
                    end
                end

                ST_DONE: begin
                    scl_low <= 1'b0;
                    sda_low <= 1'b0;
                    cfg_busy <= 1'b0;
                    cfg_done <= 1'b1;
                end

                default: begin
                    state <= ST_POWERUP_WAIT;
                end
            endcase
        end
    end

endmodule
