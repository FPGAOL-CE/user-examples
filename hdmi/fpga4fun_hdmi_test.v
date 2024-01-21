// (c) fpga4fun.com & KNJN LLC 2013-2023
// Modified for Gowin Tang Nano 9K HDMI
`define APICULA

module HDMI_test(
	input clk,
	input btn,
	output [3:0]led,
	output [2:0] tmds_d_p, tmds_d_n,
	output tmds_clk_p, tmds_clk_n
);

wire pixclk;
wire clk_TMDS;
wire lock;

reg [23:0]cnt = 0;
always @ (posedge pixclk) begin
	cnt <= cnt + 1;
end
assign led = cnt[23:20];

`ifdef APICULA
wire clk_250;
// 250M and 25M
pll_25 pll_25_inst(
	.clkin(clk),
	.clkout(clk_250),
	.clkoutd(pixclk),
	.lock(lock)
);
// this is NOT good, but CLKDIV is not supported for now
reg clk_250_r = 0;
always @ (posedge clk_250) clk_250_r <= ~clk_250_r;
assign clk_TMDS = clk_250_r;
`else
pll_25 pll_25_inst(
	.clkin(clk),
	.clkout(clk_TMDS),
	.clkoutd(),
	.lock(lock)
);

clkdiv5 clkdiv5_inst(
	.hclkin(clk_TMDS),
	.clkout(pixclk),
	.resetn(lock)
);
`endif

////////////////////////////////////////////////////////////////////////
reg [9:0] CounterX=0, CounterY=0;
reg hSync, vSync, DrawArea;
always @(posedge pixclk) DrawArea <= (CounterX<640) && (CounterY<480);

always @(posedge pixclk) CounterX <= (CounterX==799) ? 0 : CounterX+1;
always @(posedge pixclk) if(CounterX==799) CounterY <= (CounterY==524) ? 0 : CounterY+1;

always @(posedge pixclk) hSync <= (CounterX>=656) && (CounterX<752);
always @(posedge pixclk) vSync <= (CounterY>=490) && (CounterY<492);

////////////////
wire [7:0] W = btn ? {8{CounterX[7:0]==CounterY[7:0]}} : 0;
wire [7:0] A = btn ? {8{CounterX[7:5]==3'h2 && CounterY[7:5]==3'h2}} : 0;
reg [7:0] red, green, blue;
always @(posedge pixclk) red <= ({CounterX[5:0] & {6{CounterY[4:3]==~CounterX[4:3]}}, 2'b00} | W) & ~A;
always @(posedge pixclk) green <= (CounterX[7:0] & {8{CounterY[6]}} | W) & ~A;
always @(posedge pixclk) blue <= CounterY[7:0] | W | A;

////////////////////////////////////////////////////////////////////////
wire [9:0] TMDS_red, TMDS_green, TMDS_blue;
TMDS_encoder encode_R(.clk(pixclk), .VD(red  ), .CD(2'b00)        , .VDE(DrawArea), .TMDS(TMDS_red));
TMDS_encoder encode_G(.clk(pixclk), .VD(green), .CD(2'b00)        , .VDE(DrawArea), .TMDS(TMDS_green));
TMDS_encoder encode_B(.clk(pixclk), .VD(blue ), .CD({vSync,hSync}), .VDE(DrawArea), .TMDS(TMDS_blue));

//reg [3:0] TMDS_mod10=0;  // modulus 10 counter
//reg [9:0] TMDS_shift_red=0, TMDS_shift_green=0, TMDS_shift_blue=0;
//reg TMDS_shift_load=0;
//always @(posedge clk_TMDS) TMDS_shift_load <= (TMDS_mod10==4'd9);

//always @(posedge clk_TMDS)
//begin
	//TMDS_shift_red   <= TMDS_shift_load ? TMDS_red   : TMDS_shift_red  [9:1];
	//TMDS_shift_green <= TMDS_shift_load ? TMDS_green : TMDS_shift_green[9:1];
	//TMDS_shift_blue  <= TMDS_shift_load ? TMDS_blue  : TMDS_shift_blue [9:1];	
	//TMDS_mod10 <= (TMDS_mod10==4'd9) ? 4'd0 : TMDS_mod10+4'd1;
//end

wire [2:0]tmds_d;

OSER10 tmds_serdes[2:0] (
	.Q(tmds_d),
	.D0({TMDS_red[0], TMDS_green[0], TMDS_blue[0]}),
	.D1({TMDS_red[1], TMDS_green[1], TMDS_blue[1]}),
	.D2({TMDS_red[2], TMDS_green[2], TMDS_blue[2]}),
	.D3({TMDS_red[3], TMDS_green[3], TMDS_blue[3]}),
	.D4({TMDS_red[4], TMDS_green[4], TMDS_blue[4]}),
	.D5({TMDS_red[5], TMDS_green[5], TMDS_blue[5]}),
	.D6({TMDS_red[6], TMDS_green[6], TMDS_blue[6]}),
	.D7({TMDS_red[7], TMDS_green[7], TMDS_blue[7]}),
	.D8({TMDS_red[8], TMDS_green[8], TMDS_blue[8]}),
	.D9({TMDS_red[9], TMDS_green[9], TMDS_blue[9]}),
	.PCLK(pixclk),
	.FCLK(clk_TMDS),
	.RESET(~lock)
);

ELVDS_OBUF tmds_bufds[3:0] (
	.I({pixclk, tmds_d}),
	.O({tmds_clk_p, tmds_d_p}),
	.OB({tmds_clk_n, tmds_d_n})
);
endmodule

////////////////////////////////////////////////////////////////////////
module TMDS_encoder(
	input clk,
	input [7:0] VD,  // video data (red, green or blue)
	input [1:0] CD,  // control data
	input VDE,  // video data enable, to choose between CD (when VDE=0) and VD (when VDE=1)
	output reg [9:0] TMDS = 0
);

wire [3:0] Nb1s = VD[0] + VD[1] + VD[2] + VD[3] + VD[4] + VD[5] + VD[6] + VD[7];
wire XNOR = (Nb1s>4'd4) || (Nb1s==4'd4 && VD[0]==1'b0);
wire [8:0] q_m = {~XNOR, q_m[6:0] ^ VD[7:1] ^ {7{XNOR}}, VD[0]};

reg [3:0] balance_acc = 0;
wire [3:0] balance = q_m[0] + q_m[1] + q_m[2] + q_m[3] + q_m[4] + q_m[5] + q_m[6] + q_m[7] - 4'd4;
wire balance_sign_eq = (balance[3] == balance_acc[3]);
wire invert_q_m = (balance==0 || balance_acc==0) ? ~q_m[8] : balance_sign_eq;
wire [3:0] balance_acc_inc = balance - ({q_m[8] ^ ~balance_sign_eq} & ~(balance==0 || balance_acc==0));
wire [3:0] balance_acc_new = invert_q_m ? balance_acc-balance_acc_inc : balance_acc+balance_acc_inc;
wire [9:0] TMDS_data = {invert_q_m, q_m[8], q_m[7:0] ^ {8{invert_q_m}}};
wire [9:0] TMDS_code = CD[1] ? (CD[0] ? 10'b1010101011 : 10'b0101010100) : (CD[0] ? 10'b0010101011 : 10'b1101010100);

always @(posedge clk) TMDS <= VDE ? TMDS_data : TMDS_code;
always @(posedge clk) balance_acc <= VDE ? balance_acc_new : 4'h0;
endmodule

// https://github.com/sipeed/TangNano-9K-example/tree/main/hdmi
// https://github.com/YosysHQ/apicula/blob/master/examples/pll/rpll.v
module pll_25 (
	output clkout,
	output clkoutd,
	input clkin,
	output lock
);

	rPLL pll (
		.CLKOUT(clkout),
		.CLKOUTD(clkoutd),
		.CLKIN(clkin),
		.CLKFB(0),
		.RESET_P(0),
		.RESET(0),
		.FBDSEL(0),
		.IDSEL(0),
		.ODSEL(0),
		.DUTYDA(0),
		.PSDA(0),
		.FDLY(0),
		.LOCK(lock)
	);
	// f_clkout = f_clkin * FBDIV / IDIV
	// f_clkoutd = f_clkout / SDIV
	// f_vco = f_clkout * ODIV
	defparam pll.DEVICE = "GW1NR-9";
	defparam pll.FCLKIN = "27";
`ifdef APICULA
	// 27 * 37 / 4 = 249.75, 249.75/10 = 24.975
	defparam pll.FBDIV_SEL = 36; // FBDIV = FBDIV_SEL + 1
	defparam pll.IDIV_SEL =  3; // IDIV = IDIV_SEL + 1
	defparam pll.ODIV_SEL =  4; // PLL at 1000 MHz
`else
	// 27 * 37 / 8 = 124.875
	defparam pll.FBDIV_SEL = 36; // FBDIV = FBDIV_SEL + 1
	defparam pll.IDIV_SEL =  7; // IDIV = IDIV_SEL + 1
	defparam pll.ODIV_SEL =  8; // PLL at 1000 MHz
`endif
	defparam pll.CLKFB_SEL="internal";
	defparam pll.CLKOUTD3_SRC="CLKOUT";
	defparam pll.CLKOUTD_BYPASS="false";
	defparam pll.CLKOUTD_SRC="CLKOUT";
	defparam pll.CLKOUTP_BYPASS="false";
	defparam pll.CLKOUTP_DLY_STEP=0;
	defparam pll.CLKOUTP_FT_DIR=1'b1;
	defparam pll.CLKOUT_BYPASS="false";
	defparam pll.CLKOUT_DLY_STEP=0;
	defparam pll.CLKOUT_FT_DIR=1'b1;
	defparam pll.DUTYDA_SEL="1000";
	defparam pll.DYN_DA_EN="false";
	defparam pll.DYN_FBDIV_SEL="false";
	defparam pll.DYN_IDIV_SEL="false";
	defparam pll.DYN_ODIV_SEL="false";
	defparam pll.DYN_SDIV_SEL=10;
	defparam pll.PSDA_SEL="0000";
endmodule

module clkdiv5 (
	output clkout,
	input hclkin,
	input resetn
);
	CLKDIV clkdiv_inst (
		.CLKOUT(clkout),
		.HCLKIN(hclkin),
		.RESETN(resetn),
		.CALIB(0)
	);

	defparam clkdiv_inst.DIV_MODE = "5";
	defparam clkdiv_inst.GSREN = "false";
endmodule
