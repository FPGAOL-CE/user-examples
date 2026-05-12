// by He Xu, for FPGAOL2 ZYNQ+FPGA instances
// SW/LED control, draw on canvas using mouse (hold down left button) by write to framebuffer display
// Use a simple SPI interface to access memory-mapped framebuffer display, including cursor coordinate

module example(
    input clk,
    input [7:0]sw,
    output [7:0]led,
    output sck,
	output mosi,
	input miso
    );

assign led = ~sw;
    
parameter PSPI_WIDTH = 1;
parameter YELLOW = 16'hE0FF;  // 黄色RGB565格式
parameter RED = 16'h00F8;     // 红色RGB565格式
parameter YELLOW32 = 32'hE0FFE0FF;  // 两像素黄色RGB565格式
parameter RED32 = 32'h00F800F8;     // 两像素红色RGB565格式
    
reg [31:0] pspi_a;
reg [31:0] pspi_d;
reg pspi_we;
reg pspi_rd;
wire [31:0] pspi_spo;
wire pspi_ready;

reg write_in_progress = 0;   // 标志当前是否在写入过程
reg read_in_progress = 0;

wire [31:0] mouse_xy;
reg [31:0] mouse_data;
wire [15:0] mouse_x, mouse_y;
wire [31:0] mouse_addr;

assign mouse_xy = {pspi_spo[7:0], pspi_spo[15:8], pspi_spo[23:16], pspi_spo[31:24]};
assign mouse_x = mouse_xy[31:16];
assign mouse_y = mouse_xy[15:0];
assign mouse_addr = (mouse_y * 320 + mouse_x) * 2;
    
// 状态机控制读取和写入
always @(posedge clk) begin
    if (sw[0]) begin
        pspi_we <= 0;
        pspi_rd <= 0;
        write_in_progress <= 0;
        read_in_progress <= 0;
    end else begin
        // 读取第0地址的鼠标数据
        if (!read_in_progress && !write_in_progress && !pspi_we && !pspi_rd) begin
            pspi_a <= 32'd0;  // 读取第0地址
            pspi_rd <= 1'b1;  // 触发读取信号
            read_in_progress <= 1'b1; // 开始读取流程
        end 
        else if (read_in_progress) begin
            pspi_rd <= 1'b0;
            if (read_in_progress && pspi_ready) begin
                read_in_progress <= 0;
                if (mouse_xy != mouse_data) begin
                    mouse_data <= mouse_xy;
                    write_in_progress <= 1'b1;  // 启动写入流程
                    pspi_a <= mouse_addr;
                    pspi_d <= sw[1] ? RED32 : YELLOW32;
                    pspi_we <= 1'b1;
                end
            end
        end
        else if (write_in_progress) begin
            pspi_we <= 1'b0;
            // 写入RED32数据到目标地址
            if (write_in_progress && pspi_ready) begin
                write_in_progress <= 1'b0; // 写入完成
            end
        end
    end
end

pspi_host #(.PSPI_WIDTH(PSPI_WIDTH)) pspi_host_inst (
		.clk(clk),
		.rst(sw[0]),

		.a(pspi_a),
		.d(pspi_d),
		.we(pspi_we),
		.rd(pspi_rd),
		.spo(pspi_spo),
		.ready(pspi_ready),

		.sck(sck),
		.mosi(mosi),
		.miso(miso)
	);

endmodule

/**
 * File              : pspi_host.v
 * License           : GPL-3.0-or-later
 * Author            : Peter Gu <github.com/ustcpetergu>
 * Date              : 2020.11.25
 * Last Modified Date: 2024.04.13
 */
`timescale 1ns / 1ps
// A simple spi-like interface for mid-speed data transfer
// Used in FPGAOL for "persistent storage" emulation
// 
// guests detect sck posedge, so shift out data on negedge

module pspi_host #(
	parameter PSPI_WIDTH = 8
)(
        input clk,
        input rst,
        input [31:0]a,
        input [31:0]d,
        input we,
		input rd,
        output [31:0]spo,
		output ready,

		output reg sck,
		output reg [PSPI_WIDTH-1:0]mosi,
		input [PSPI_WIDTH-1:0]miso
    );

	(* mark_debug = "true" *) reg [31:0]pspo;
	assign spo = {pspo[7:0], pspo[15:8], pspo[23:16], pspo[31:24]};
	(* mark_debug = "true" *) reg [31:0]pd;
	(* mark_debug = "true" *) reg [31:0]pa; // depend on ZYNQ AXI address
	reg pwe;
	reg [5:0]shiftcnt;
	reg [7:0]rstcnt;

	reg [PSPI_WIDTH-1:0]miso_r;
	always @ (posedge clk) begin
		miso_r <= miso;
	end

    reg [4:0]clkcounter = 0;
    always @ (posedge clk) begin
        clkcounter <= clkcounter + 1;
    end
    wire clk_pulse_slow = (clkcounter[2:0] == 0); // ~8 MHz would be OK

	(* mark_debug = "true" *) reg [3:0]pstate;
	localparam RST = 0;
	localparam IDLE = 1;
	localparam STARTSIGN = 2;
	localparam RDWR = 3;
	localparam ADDR = 4;
	localparam WDATA = 5;
	localparam WAIT = 6;
	localparam RDATA = 7;

	localparam CNT_MAX = 32 / PSPI_WIDTH - 1;

	assign ready = !(rd | we) & pstate == IDLE;

    always @ (posedge clk) begin
		// do not send sck when idle, it'll reset the bus
		if (clk_pulse_slow) sck <= pstate == IDLE ? 1'b1 : ~sck;
        if (rst) begin
			mosi <= 32'hFFFFFFFF;
			pstate <= RST;
			rstcnt <= 0;
		end else begin
			case (pstate)
				RST: begin // reset bus by >~256 sck with mosi[0] high
					rstcnt <= rstcnt + 1;
					if (rstcnt == 8'hFF) pstate <= IDLE;
				end
				IDLE: begin
					mosi <= 32'hFFFFFFFF;
					if (rd | we) begin
						pwe <= we;
						pd <= {d[7:0], d[15:8], d[23:16], d[31:24]};
						pa <= {8'b01, a[23:0]};
						pstate <= STARTSIGN;
					end
				end
				STARTSIGN: begin
					if (clk_pulse_slow) begin
						if (sck) begin
							mosi <= 32'hFFFFFFFE;
							pstate <= RDWR;
						end
					end
				end
				RDWR: begin
					if (clk_pulse_slow) begin
						if (sck) begin
							mosi <= {{31{1'b1}}, pwe ? 1'b1 : 1'b0};
							pstate <= ADDR;
							shiftcnt <= CNT_MAX;
						end
					end
				end
				ADDR: begin
					if (clk_pulse_slow) begin
						if (sck) begin
							shiftcnt <= shiftcnt - 1;
							pa <= {pa[31-PSPI_WIDTH:0], {PSPI_WIDTH{1'b0}}};
							mosi <= pa[31:32-PSPI_WIDTH];
							if (shiftcnt == 0) begin
								shiftcnt <= CNT_MAX;
								pstate <= pwe ? WDATA : WAIT;
							end
						end
					end
				end
				WDATA: begin
					if (clk_pulse_slow) begin
						if (sck) begin
							shiftcnt <= shiftcnt - 1;
							pd <= {pd[31-PSPI_WIDTH:0], {PSPI_WIDTH{1'b0}}};
							mosi <= pd[31:32-PSPI_WIDTH];
							if (shiftcnt == 0) begin
								pstate <= WAIT;
							end
						end
					end
				end
				WAIT: begin
					if (clk_pulse_slow) begin
						if (sck) begin
							shiftcnt <= CNT_MAX;
							mosi <= 32'hFFFFFFFF;
							if (!miso_r[0]) pstate <= pwe ? IDLE : RDATA;
						end
					end
				end
				RDATA: begin
					if (clk_pulse_slow) begin
						if (!sck) begin // only here is read, so shift at posedge
							pspo <= {pspo[31-PSPI_WIDTH:0], miso_r};
							shiftcnt <= shiftcnt - 1;
							if (shiftcnt == 0) begin
								pstate <= IDLE;
							end
						end
					end
				end
			endcase
		end
    end

endmodule
