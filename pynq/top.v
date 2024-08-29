// Basys3 test
// by petergu 2023.4.23
`timescale 1ns / 1ps
//`define NOPS7
 
module top(
	input clk,
	output [3:0]led,
	input [1:0]sw
    );

	wire psclk = FCLK_CLK_buffered[sw];
	reg [31:0]cnt = 0;
	always @ (posedge psclk) begin
		cnt <= cnt + 1;
	end
	assign led[3:2] = cnt[28:27];
	assign led[1:0] = sw[1:0];
	//assign led = {M_AXI_GP0_ARESETN, M_AXI_GP0_WLAST, M_AXI_GP0_RVALID, M_AXI_GP0_ACLK}; // this RVALID has ERROR: Invalid global constant node 'INT_L_X18Y95/VCC_WIRE'
	//assign led = M_AXI_GP0_AWLEN; // WDATA: same L_X18Y95/VCC_WIRE
	//assign led = axiw[3:0];

    wire [63:0] emio_gpio_o;
    wire [63:0] emio_gpio_t;
    wire [63:0] emio_gpio_i;

	//assign led = emio_gpio_o[3:0];

    //assign led = emio_gpio_o[3:0] ^ btn[3:0];
    //assign emio_gpio_i = 'd0;

	wire [3:0]FCLK_CLK_unbuffered;
	wire [3:0]FCLK_CLK_buffered;
	BUFG FCLK_CLK_0_BUFG (.I(FCLK_CLK_unbuffered[0]), .O(FCLK_CLK_buffered[0]));
	BUFG FCLK_CLK_1_BUFG (.I(FCLK_CLK_unbuffered[1]), .O(FCLK_CLK_buffered[1]));
	BUFG FCLK_CLK_2_BUFG (.I(FCLK_CLK_unbuffered[2]), .O(FCLK_CLK_buffered[2]));
	BUFG FCLK_CLK_3_BUFG (.I(FCLK_CLK_unbuffered[3]), .O(FCLK_CLK_buffered[3]));


	//M_AXI_GP0
	localparam C_M_AXI_GP0_THREAD_ID_WIDTH = 12;

	// -- Output

	wire M_AXI_GP0_ARESETN;
	wire M_AXI_GP0_ARVALID;
	wire M_AXI_GP0_AWVALID;
	wire M_AXI_GP0_BREADY;
	wire M_AXI_GP0_RREADY;
	wire M_AXI_GP0_WLAST;
	wire M_AXI_GP0_WVALID;
	wire [(C_M_AXI_GP0_THREAD_ID_WIDTH - 1):0] M_AXI_GP0_ARID;
	wire [(C_M_AXI_GP0_THREAD_ID_WIDTH - 1):0] M_AXI_GP0_AWID;
	wire [(C_M_AXI_GP0_THREAD_ID_WIDTH - 1):0] M_AXI_GP0_WID;
	wire [1:0] M_AXI_GP0_ARBURST;
	wire [1:0] M_AXI_GP0_ARLOCK;
	wire [2:0] M_AXI_GP0_ARSIZE;
	wire [1:0] M_AXI_GP0_AWBURST;
	wire [1:0] M_AXI_GP0_AWLOCK;
	wire [2:0] M_AXI_GP0_AWSIZE;
	wire [2:0] M_AXI_GP0_ARPROT;
	wire [2:0] M_AXI_GP0_AWPROT;
	wire [31:0] M_AXI_GP0_ARADDR;
	wire [31:0] M_AXI_GP0_AWADDR;
	wire [31:0] M_AXI_GP0_WDATA;
	wire [3:0] M_AXI_GP0_ARCACHE;
	wire [3:0] M_AXI_GP0_ARLEN;
	wire [3:0] M_AXI_GP0_ARQOS;
	wire [3:0] M_AXI_GP0_AWCACHE;
	wire [3:0] M_AXI_GP0_AWLEN;
	wire [3:0] M_AXI_GP0_AWQOS;
	wire [3:0] M_AXI_GP0_WSTRB; 

	//assign led = M_AXI_GP0_ARESETN|| M_AXI_GP0_ARVALID|| M_AXI_GP0_AWVALID|| M_AXI_GP0_BREADY|| M_AXI_GP0_RREADY|| M_AXI_GP0_WLAST|| M_AXI_GP0_WVALID|| M_AXI_GP0_ARID|| M_AXI_GP0_AWID|| M_AXI_GP0_WID|| M_AXI_GP0_ARBURST|| M_AXI_GP0_ARLOCK|| M_AXI_GP0_ARSIZE|| M_AXI_GP0_AWBURST|| M_AXI_GP0_AWLOCK|| M_AXI_GP0_AWSIZE|| M_AXI_GP0_ARPROT|| M_AXI_GP0_AWPROT|| M_AXI_GP0_ARADDR|| M_AXI_GP0_AWADDR|| M_AXI_GP0_WDATA|| M_AXI_GP0_ARCACHE|| M_AXI_GP0_ARLEN|| M_AXI_GP0_ARQOS|| M_AXI_GP0_AWCACHE|| M_AXI_GP0_AWLEN|| M_AXI_GP0_AWQOS|| M_AXI_GP0_WSTRB;

	// -- Input  

	wire M_AXI_GP0_ACLK = FCLK_CLK_buffered[0];
	wire M_AXI_GP0_ARREADY = 1;
	wire M_AXI_GP0_AWREADY = 1;
	wire M_AXI_GP0_BVALID = bvalid; // *
	wire M_AXI_GP0_RLAST = 1;
	wire M_AXI_GP0_RVALID = rvalid; // *
	wire M_AXI_GP0_WREADY = 1;
	wire [(C_M_AXI_GP0_THREAD_ID_WIDTH - 1):0] M_AXI_GP0_BID = M_AXI_GP0_WID;
	wire [(C_M_AXI_GP0_THREAD_ID_WIDTH - 1):0] M_AXI_GP0_RID = M_AXI_GP0_ARID;
	wire [1:0] M_AXI_GP0_BRESP = 0;
	wire [1:0] M_AXI_GP0_RRESP = 0;
	wire [31:0] M_AXI_GP0_RDATA = 32'haabbccdd | axiw;

	reg [31:0]axiw = 0;
	reg bvalid;
	reg rvalid;
	always @ (posedge M_AXI_GP0_ACLK) begin
		if (M_AXI_GP0_WVALID) 
			axiw <= M_AXI_GP0_WDATA;
		if (M_AXI_GP0_ARVALID & M_AXI_GP0_ARREADY) begin
			rvalid <= 1;
		end
		if (rvalid & M_AXI_GP0_RREADY) begin
			rvalid <= 0;
		end
		if (M_AXI_GP0_WVALID & M_AXI_GP0_WREADY) begin
			bvalid <= 1;
		end
		if (bvalid & M_AXI_GP0_BREADY) begin
			bvalid <= 0;
		end
	end

	//assign led = {bvalid, rvalid, M_AXI_GP0_ARVALID, M_AXI_GP0_RREADY};

	//M_AXI_GP1
	localparam C_M_AXI_GP1_THREAD_ID_WIDTH = 12;

	// -- Output

	wire M_AXI_GP1_ARESETN;
	wire M_AXI_GP1_ARVALID;
	wire M_AXI_GP1_AWVALID;
	wire M_AXI_GP1_BREADY;
	wire M_AXI_GP1_RREADY;
	wire M_AXI_GP1_WLAST;
	wire M_AXI_GP1_WVALID;
	wire [(C_M_AXI_GP1_THREAD_ID_WIDTH - 1):0] M_AXI_GP1_ARID;
	wire [(C_M_AXI_GP1_THREAD_ID_WIDTH - 1):0] M_AXI_GP1_AWID;
	wire [(C_M_AXI_GP1_THREAD_ID_WIDTH - 1):0] M_AXI_GP1_WID;
	wire [1:0] M_AXI_GP1_ARBURST;
	wire [1:0] M_AXI_GP1_ARLOCK;
	wire [2:0] M_AXI_GP1_ARSIZE;
	wire [1:0] M_AXI_GP1_AWBURST;
	wire [1:0] M_AXI_GP1_AWLOCK;
	wire [2:0] M_AXI_GP1_AWSIZE;
	wire [2:0] M_AXI_GP1_ARPROT;
	wire [2:0] M_AXI_GP1_AWPROT;
	wire [31:0] M_AXI_GP1_ARADDR;
	wire [31:0] M_AXI_GP1_AWADDR;
	wire [31:0] M_AXI_GP1_WDATA;
	wire [3:0] M_AXI_GP1_ARCACHE;
	wire [3:0] M_AXI_GP1_ARLEN;
	wire [3:0] M_AXI_GP1_ARQOS;
	wire [3:0] M_AXI_GP1_AWCACHE;
	wire [3:0] M_AXI_GP1_AWLEN;
	wire [3:0] M_AXI_GP1_AWQOS;
	wire [3:0] M_AXI_GP1_WSTRB; 

	// -- Input  

	wire M_AXI_GP1_ACLK = FCLK_CLK_buffered[0];
	wire M_AXI_GP1_ARREADY = 1;
	wire M_AXI_GP1_AWREADY = 1;
	wire M_AXI_GP1_BVALID = bvalid1; // *
	wire M_AXI_GP1_RLAST = 1;
	wire M_AXI_GP1_RVALID = rvalid1; // *
	wire M_AXI_GP1_WREADY = 1;
	wire [(C_M_AXI_GP1_THREAD_ID_WIDTH - 1):0] M_AXI_GP1_BID = 0;
	wire [(C_M_AXI_GP1_THREAD_ID_WIDTH - 1):0] M_AXI_GP1_RID = 0;
	wire [1:0] M_AXI_GP1_BRESP = 0;
	wire [1:0] M_AXI_GP1_RRESP = 0;
	wire [31:0] M_AXI_GP1_RDATA = 32'habcdabcd;  

	reg [31:0]axiw1;
	reg bvalid1;
	reg rvalid1;
	always @ (posedge M_AXI_GP0_ACLK) begin
		if (M_AXI_GP1_WVALID) 
			axiw1 <= M_AXI_GP1_WDATA;
		if (M_AXI_GP1_ARVALID & M_AXI_GP1_ARREADY) begin
			rvalid1 <= 1;
		end
		if (rvalid1 & M_AXI_GP1_RREADY) begin
			rvalid1 <= 0;
		end
		if (M_AXI_GP1_WVALID & M_AXI_GP1_WREADY) begin
			bvalid1 <= 1;
		end
		if (bvalid1 & M_AXI_GP1_BREADY) begin
			bvalid1 <= 0;
		end
	end

`ifndef NOPS7
//    (* KEEP, DONT_TOUCH *)
    PS7 zynq7 (
	.DMA0DATYPE			        (),
	.DMA0DAVALID			    (),
	.DMA0DRREADY			    (),
	.DMA0RSTN			        (),
	.DMA1DATYPE	              	(),
	.DMA1DAVALID			    (),
	.DMA1DRREADY			    (),
	.DMA1RSTN			        (),
	.DMA2DATYPE			        (),
	.DMA2DAVALID			    (),
	.DMA2DRREADY			    (),
	.DMA2RSTN			(),
	.DMA3DATYPE			(),
	.DMA3DAVALID			(),
	.DMA3DRREADY			(),
	.DMA3RSTN			(),
	.EMIOCAN0PHYTX			(),
	.EMIOCAN1PHYTX			(),
	.EMIOENET0GMIITXD		(),
	.EMIOENET0GMIITXEN		(),
	.EMIOENET0GMIITXER		(),
	.EMIOENET0MDIOMDC		(),
	.EMIOENET0MDIOO			(),
	.EMIOENET0MDIOTN		(),
	.EMIOENET0PTPDELAYREQRX		(),
	.EMIOENET0PTPDELAYREQTX		(),
	.EMIOENET0PTPPDELAYREQRX	(),
	.EMIOENET0PTPPDELAYREQTX	(),
	.EMIOENET0PTPPDELAYRESPRX	(),
	.EMIOENET0PTPPDELAYRESPTX	(),
	.EMIOENET0PTPSYNCFRAMERX	(),
	.EMIOENET0PTPSYNCFRAMETX	(),
	.EMIOENET0SOFRX			(),
	.EMIOENET0SOFTX			(),
	.EMIOENET1GMIITXD		(),
	.EMIOENET1GMIITXEN		(),
	.EMIOENET1GMIITXER		(),
	.EMIOENET1MDIOMDC		(),
	.EMIOENET1MDIOO			(),
	.EMIOENET1MDIOTN		(),
	.EMIOENET1PTPDELAYREQRX		(),
	.EMIOENET1PTPDELAYREQTX		(),
	.EMIOENET1PTPPDELAYREQRX	(),
	.EMIOENET1PTPPDELAYREQTX	(),
	.EMIOENET1PTPPDELAYRESPRX	(),
	.EMIOENET1PTPPDELAYRESPTX	(),
	.EMIOENET1PTPSYNCFRAMERX	(),
	.EMIOENET1PTPSYNCFRAMETX	(),
	.EMIOENET1SOFRX			(),
	.EMIOENET1SOFTX			(),
	.EMIOGPIOO			(emio_gpio_o),
	.EMIOGPIOTN			(emio_gpio_t),
	.EMIOI2C0SCLO			(),
	.EMIOI2C0SCLTN			(),
	.EMIOI2C0SDAO			(),
	.EMIOI2C0SDATN			(),
	.EMIOI2C1SCLO			(),
	.EMIOI2C1SCLTN			(),
	.EMIOI2C1SDAO			(),
	.EMIOI2C1SDATN			(),
	.EMIOPJTAGTDO			(),
	.EMIOPJTAGTDTN			(),
	.EMIOSDIO0BUSPOW		(),
	.EMIOSDIO0BUSVOLT		(),
	.EMIOSDIO0CLK			(),
	.EMIOSDIO0CMDO			(),
	.EMIOSDIO0CMDTN			(),
	.EMIOSDIO0DATAO			(),
	.EMIOSDIO0DATATN		(),
	.EMIOSDIO0LED			(),
	.EMIOSDIO1BUSPOW		(),
	.EMIOSDIO1BUSVOLT		(),
	.EMIOSDIO1CLK			(),
	.EMIOSDIO1CMDO			(),
	.EMIOSDIO1CMDTN			(),
	.EMIOSDIO1DATAO			(),
	.EMIOSDIO1DATATN		(),
	.EMIOSDIO1LED			(),
	.EMIOSPI0MO			    (),
	.EMIOSPI0MOTN			(),
	.EMIOSPI0SCLKO			(),
	.EMIOSPI0SCLKTN			(),
	.EMIOSPI0SO			    (),
	.EMIOSPI0SSNTN			(),
	.EMIOSPI0SSON			(),
	.EMIOSPI0STN			(),
	.EMIOSPI1MO			    (),
	.EMIOSPI1MOTN			(),
	.EMIOSPI1SCLKO			(),
	.EMIOSPI1SCLKTN			(),
	.EMIOSPI1SO			    (),
	.EMIOSPI1SSNTN			(),
	.EMIOSPI1SSON			(),
	.EMIOSPI1STN			(),
	.EMIOTRACECTL			(),
	.EMIOTRACEDATA			(),
	.EMIOTTC0WAVEO			(),
	.EMIOTTC1WAVEO			(),
	.EMIOUART0DTRN			(),
	.EMIOUART0RTSN			(),
	.EMIOUART0TX			(),
	.EMIOUART1DTRN			(),
	.EMIOUART1RTSN			(),
	.EMIOUART1TX			(),
	.EMIOUSB0PORTINDCTL		(),
	.EMIOUSB0VBUSPWRSELECT	(),
	.EMIOUSB1PORTINDCTL		(),
	.EMIOUSB1VBUSPWRSELECT	(),
	.EMIOWDTRSTO			(),
	.EVENTEVENTO			(),
	.EVENTSTANDBYWFE		(),
	.EVENTSTANDBYWFI		(),
	.FCLKCLK			    (FCLK_CLK_unbuffered),
	.FCLKRESETN			    (),
	.FTMTF2PTRIGACK			(),
	.FTMTP2FDEBUG			(),
	.FTMTP2FTRIG			(),
	.IRQP2F				    (),
	.MAXIGP0ARADDR			(M_AXI_GP0_ARADDR),
	.MAXIGP0ARBURST			(M_AXI_GP0_ARBURST			),
	.MAXIGP0ARCACHE			(M_AXI_GP0_ARCACHE			),
	.MAXIGP0ARESETN			(M_AXI_GP0_ARESETN			),
	.MAXIGP0ARID			(M_AXI_GP0_ARID			),
	.MAXIGP0ARLEN			(M_AXI_GP0_ARLEN			),
	.MAXIGP0ARLOCK			(M_AXI_GP0_ARLOCK			),
	.MAXIGP0ARPROT			(M_AXI_GP0_ARPROT			),
	.MAXIGP0ARQOS			(M_AXI_GP0_ARQOS			),
	.MAXIGP0ARSIZE			(M_AXI_GP0_ARSIZE			),
	.MAXIGP0ARVALID			(M_AXI_GP0_ARVALID			),
	.MAXIGP0AWADDR			(M_AXI_GP0_AWADDR			),
	.MAXIGP0AWBURST			(M_AXI_GP0_AWBURST			),
	.MAXIGP0AWCACHE			(M_AXI_GP0_AWCACHE			),
	.MAXIGP0AWID			(M_AXI_GP0_AWID			),
	.MAXIGP0AWLEN			(M_AXI_GP0_AWLEN			),
	.MAXIGP0AWLOCK			(M_AXI_GP0_AWLOCK			),
	.MAXIGP0AWPROT			(M_AXI_GP0_AWPROT			),
	.MAXIGP0AWQOS			(M_AXI_GP0_AWQOS			),
	.MAXIGP0AWSIZE			(M_AXI_GP0_AWSIZE			),
	.MAXIGP0AWVALID			(M_AXI_GP0_AWVALID			),
	.MAXIGP0BREADY			(M_AXI_GP0_BREADY			),
	.MAXIGP0RREADY			(M_AXI_GP0_RREADY			),
	.MAXIGP0WDATA			(M_AXI_GP0_WDATA			),
	.MAXIGP0WID			(M_AXI_GP0_WID			),
	.MAXIGP0WLAST			(M_AXI_GP0_WLAST			),
	.MAXIGP0WSTRB			(M_AXI_GP0_WSTRB			),
	.MAXIGP0WVALID			(M_AXI_GP0_WVALID			),
	.MAXIGP1ARADDR			(MAXIGP1ARADDR			),
	.MAXIGP1ARBURST			(MAXIGP1ARBURST			),
	.MAXIGP1ARCACHE			(MAXIGP1ARCACHE			),
	.MAXIGP1ARESETN			(MAXIGP1ARESETN			),
	.MAXIGP1ARID			(MAXIGP1ARID			),
	.MAXIGP1ARLEN			(MAXIGP1ARLEN			),
	.MAXIGP1ARLOCK			(MAXIGP1ARLOCK			),
	.MAXIGP1ARPROT			(MAXIGP1ARPROT			),
	.MAXIGP1ARQOS			(MAXIGP1ARQOS			),
	.MAXIGP1ARSIZE			(MAXIGP1ARSIZE			),
	.MAXIGP1ARVALID			(MAXIGP1ARVALID			),
	.MAXIGP1AWADDR			(MAXIGP1AWADDR			),
	.MAXIGP1AWBURST			(MAXIGP1AWBURST			),
	.MAXIGP1AWCACHE			(MAXIGP1AWCACHE			),
	.MAXIGP1AWID			(MAXIGP1AWID			),
	.MAXIGP1AWLEN			(MAXIGP1AWLEN			),
	.MAXIGP1AWLOCK			(MAXIGP1AWLOCK			),
	.MAXIGP1AWPROT			(MAXIGP1AWPROT			),
	.MAXIGP1AWQOS			(MAXIGP1AWQOS			),
	.MAXIGP1AWSIZE			(MAXIGP1AWSIZE			),
	.MAXIGP1AWVALID			(MAXIGP1AWVALID			),
	.MAXIGP1BREADY			(MAXIGP1BREADY			),
	.MAXIGP1RREADY			(MAXIGP1RREADY			),
	.MAXIGP1WDATA			(MAXIGP1WDATA			),
	.MAXIGP1WID			(MAXIGP1WID			),
	.MAXIGP1WLAST			(MAXIGP1WLAST			),
	.MAXIGP1WSTRB			(MAXIGP1WSTRB			),
	.MAXIGP1WVALID			(MAXIGP1WVALID			),
	.SAXIACPARESETN			(),
	.SAXIACPARREADY			(),
	.SAXIACPAWREADY			(),
	.SAXIACPBID			(),
	.SAXIACPBRESP			(),
	.SAXIACPBVALID			(),
	.SAXIACPRDATA			(),
	.SAXIACPRID			(),
	.SAXIACPRLAST			(),
	.SAXIACPRRESP			(),
	.SAXIACPRVALID			(),
	.SAXIACPWREADY			(),
	.SAXIGP0ARESETN			(),
	.SAXIGP0ARREADY			(),
	.SAXIGP0AWREADY			(),
	.SAXIGP0BID			(),
	.SAXIGP0BRESP			(),
	.SAXIGP0BVALID			(),
	.SAXIGP0RDATA			(),
	.SAXIGP0RID			(),
	.SAXIGP0RLAST			(),
	.SAXIGP0RRESP			(),
	.SAXIGP0RVALID			(),
	.SAXIGP0WREADY			(),
	.SAXIGP1ARESETN			(),
	.SAXIGP1ARREADY			(),
	.SAXIGP1AWREADY			(),
	.SAXIGP1BID			(),
	.SAXIGP1BRESP			(),
	.SAXIGP1BVALID			(),
	.SAXIGP1RDATA			(),
	.SAXIGP1RID			(),
	.SAXIGP1RLAST			(),
	.SAXIGP1RRESP			(),
	.SAXIGP1RVALID			(),
	.SAXIGP1WREADY			(),
	.SAXIHP0ARESETN			(),
	.SAXIHP0ARREADY			(),
	.SAXIHP0AWREADY			(),
	.SAXIHP0BID			(),
	.SAXIHP0BRESP			(),
	.SAXIHP0BVALID			(),
	.SAXIHP0RACOUNT			(),
	.SAXIHP0RCOUNT			(),
	.SAXIHP0RDATA			(),
	.SAXIHP0RID			(),
	.SAXIHP0RLAST			(),
	.SAXIHP0RRESP			(),
	.SAXIHP0RVALID			(),
	.SAXIHP0WACOUNT			(),
	.SAXIHP0WCOUNT			(),
	.SAXIHP0WREADY			(),
	.SAXIHP1ARESETN			(),
	.SAXIHP1ARREADY			(),
	.SAXIHP1AWREADY			(),
	.SAXIHP1BID			(),
	.SAXIHP1BRESP			(),
	.SAXIHP1BVALID			(),
	.SAXIHP1RACOUNT			(),
	.SAXIHP1RCOUNT			(),
	.SAXIHP1RDATA			(),
	.SAXIHP1RID			(),
	.SAXIHP1RLAST			(),
	.SAXIHP1RRESP			(),
	.SAXIHP1RVALID			(),
	.SAXIHP1WACOUNT			(),
	.SAXIHP1WCOUNT			(),
	.SAXIHP1WREADY			(),
	.SAXIHP2ARESETN			(),
	.SAXIHP2ARREADY			(),
	.SAXIHP2AWREADY			(),
	.SAXIHP2BID			(),
	.SAXIHP2BRESP			(),
	.SAXIHP2BVALID			(),
	.SAXIHP2RACOUNT			(),
	.SAXIHP2RCOUNT			(),
	.SAXIHP2RDATA			(),
	.SAXIHP2RID			(),
	.SAXIHP2RLAST			(),
	.SAXIHP2RRESP			(),
	.SAXIHP2RVALID			(),
	.SAXIHP2WACOUNT			(),
	.SAXIHP2WCOUNT			(),
	.SAXIHP2WREADY			(),
	.SAXIHP3ARESETN			(),
	.SAXIHP3ARREADY			(),
	.SAXIHP3AWREADY			(),
	.SAXIHP3BID			(),
	.SAXIHP3BRESP			(),
	.SAXIHP3BVALID			(),
	.SAXIHP3RACOUNT			(),
	.SAXIHP3RCOUNT			(),
	.SAXIHP3RDATA			(),
	.SAXIHP3RID			(),
	.SAXIHP3RLAST			(),
	.SAXIHP3RRESP			(),
	.SAXIHP3RVALID			(),
	.SAXIHP3WACOUNT			(),
	.SAXIHP3WCOUNT			(),
	.SAXIHP3WREADY			(),
	.DDRA				(),
	.DDRBA				(),
	.DDRCASB			(),
	.DDRCKE				(),
	.DDRCKN				(),
	.DDRCKP				(),
	.DDRCSB				(),
	.DDRDM				(),
	.DDRDQ				(),
	.DDRDQSN			(),
	.DDRDQSP			(),
	.DDRDRSTB			(),
	.DDRODT				(),
	.DDRRASB			(),
	.DDRVRN				(),
	.DDRVRP				(),
	.DDRWEB				(),
	.MIO				(),
	.PSCLK				(),
	.PSPORB				(),
	.PSSRSTB			(),
	.DDRARB				(),
	.DMA0ACLK			(),
	.DMA0DAREADY			(),
	.DMA0DRLAST			(),
	.DMA0DRTYPE			(),
	.DMA0DRVALID			(),
	.DMA1ACLK			(),
	.DMA1DAREADY			(),
	.DMA1DRLAST			(),
	.DMA1DRTYPE			(),
	.DMA1DRVALID			(),
	.DMA2ACLK			(),
	.DMA2DAREADY			(),
	.DMA2DRLAST			(),
	.DMA2DRTYPE			(),
	.DMA2DRVALID			(),
	.DMA3ACLK			(),
	.DMA3DAREADY			(),
	.DMA3DRLAST			(),
	.DMA3DRTYPE			(),
	.DMA3DRVALID			(),
	.EMIOCAN0PHYRX			(),
	.EMIOCAN1PHYRX			(),
	.EMIOENET0EXTINTIN		(),
	.EMIOENET0GMIICOL		(),
	.EMIOENET0GMIICRS		(),
	.EMIOENET0GMIIRXCLK		(),
	.EMIOENET0GMIIRXD		(),
	.EMIOENET0GMIIRXDV		(),
	.EMIOENET0GMIIRXER		(),
	.EMIOENET0GMIITXCLK		(),
	.EMIOENET0MDIOI			(),
	.EMIOENET1EXTINTIN		(),
	.EMIOENET1GMIICOL		(),
	.EMIOENET1GMIICRS		(),
	.EMIOENET1GMIIRXCLK		(),
	.EMIOENET1GMIIRXD		(),
	.EMIOENET1GMIIRXDV		(),
	.EMIOENET1GMIIRXER		(),
	.EMIOENET1GMIITXCLK		(),
	.EMIOENET1MDIOI			(),
	.EMIOGPIOI			(emio_gpio_i),
	.EMIOI2C0SCLI			(),
	.EMIOI2C0SDAI			(),
	.EMIOI2C1SCLI			(),
	.EMIOI2C1SDAI			(),
	.EMIOPJTAGTCK			(),
	.EMIOPJTAGTDI			(),
	.EMIOPJTAGTMS			(),
	.EMIOSDIO0CDN			(),
	.EMIOSDIO0CLKFB			(),
	.EMIOSDIO0CMDI			(),
	.EMIOSDIO0DATAI			(),
	.EMIOSDIO0WP			(),
	.EMIOSDIO1CDN			(),
	.EMIOSDIO1CLKFB			(),
	.EMIOSDIO1CMDI			(),
	.EMIOSDIO1DATAI			(),
	.EMIOSDIO1WP			(),
	.EMIOSPI0MI			(),
	.EMIOSPI0SCLKI			(),
	.EMIOSPI0SI			(),
	.EMIOSPI0SSIN			(),
	.EMIOSPI1MI			(),
	.EMIOSPI1SCLKI			(),
	.EMIOSPI1SI			(),
	.EMIOSPI1SSIN			(),
	.EMIOSRAMINTIN			(),
	.EMIOTRACECLK			(),
	.EMIOTTC0CLKI			(),
	.EMIOTTC1CLKI			(),
	.EMIOUART0CTSN			(),
	.EMIOUART0DCDN			(),
	.EMIOUART0DSRN			(),
	.EMIOUART0RIN			(),
	.EMIOUART0RX			(),
	.EMIOUART1CTSN			(),
	.EMIOUART1DCDN			(),
	.EMIOUART1DSRN			(),
	.EMIOUART1RIN			(),
	.EMIOUART1RX			(),
	.EMIOUSB0VBUSPWRFAULT		(),
	.EMIOUSB1VBUSPWRFAULT		(),
	.EMIOWDTCLKI			(),
	.EVENTEVENTI			(),
	.FCLKCLKTRIGN			(),
	.FPGAIDLEN			(),
	.FTMDTRACEINATID		(),
	.FTMDTRACEINCLOCK		(),
	.FTMDTRACEINDATA		(),
	.FTMDTRACEINVALID		(),
	.FTMTF2PDEBUG			(),
	.FTMTF2PTRIG			(),
	.FTMTP2FTRIGACK			(),
	.IRQF2P				(),
	.MAXIGP0ACLK			(M_AXI_GP0_ACLK			),
	.MAXIGP0ARREADY			(M_AXI_GP0_ARREADY			),
	.MAXIGP0AWREADY			(M_AXI_GP0_AWREADY			),
	.MAXIGP0BID			(M_AXI_GP0_BID			),
	.MAXIGP0BRESP			(M_AXI_GP0_BRESP			),
	.MAXIGP0BVALID			(M_AXI_GP0_BVALID			),
	.MAXIGP0RDATA			(M_AXI_GP0_RDATA			),
	.MAXIGP0RID			(M_AXI_GP0_RID			),
	.MAXIGP0RLAST			(M_AXI_GP0_RLAST			),
	.MAXIGP0RRESP			(M_AXI_GP0_RRESP			),
	.MAXIGP0RVALID			(M_AXI_GP0_RVALID			),
	.MAXIGP0WREADY			(M_AXI_GP0_WREADY			),
	.MAXIGP1ACLK			(MAXIGP1ACLK			),
	.MAXIGP1ARREADY			(MAXIGP1ARREADY			),
	.MAXIGP1AWREADY			(MAXIGP1AWREADY			),
	.MAXIGP1BID			(MAXIGP1BID			),
	.MAXIGP1BRESP			(MAXIGP1BRESP			),
	.MAXIGP1BVALID			(MAXIGP1BVALID			),
	.MAXIGP1RDATA			(MAXIGP1RDATA			),
	.MAXIGP1RID			(MAXIGP1RID			),
	.MAXIGP1RLAST			(MAXIGP1RLAST			),
	.MAXIGP1RRESP			(MAXIGP1RRESP			),
	.MAXIGP1RVALID			(MAXIGP1RVALID			),
	.MAXIGP1WREADY			(MAXIGP1WREADY			),
	.SAXIACPACLK			(),
	.SAXIACPARADDR			(),
	.SAXIACPARBURST			(),
	.SAXIACPARCACHE			(),
	.SAXIACPARID			(),
	.SAXIACPARLEN			(),
	.SAXIACPARLOCK			(),
	.SAXIACPARPROT			(),
	.SAXIACPARQOS			(),
	.SAXIACPARSIZE			(),
	.SAXIACPARUSER			(),
	.SAXIACPARVALID			(),
	.SAXIACPAWADDR			(),
	.SAXIACPAWBURST			(),
	.SAXIACPAWCACHE			(),
	.SAXIACPAWID			(),
	.SAXIACPAWLEN			(),
	.SAXIACPAWLOCK			(),
	.SAXIACPAWPROT			(),
	.SAXIACPAWQOS			(),
	.SAXIACPAWSIZE			(),
	.SAXIACPAWUSER			(),
	.SAXIACPAWVALID			(),
	.SAXIACPBREADY			(),
	.SAXIACPRREADY			(),
	.SAXIACPWDATA			(),
	.SAXIACPWID			(),
	.SAXIACPWLAST			(),
	.SAXIACPWSTRB			(),
	.SAXIACPWVALID			(),
	.SAXIGP0ACLK			(),
	.SAXIGP0ARADDR			(),
	.SAXIGP0ARBURST			(),
	.SAXIGP0ARCACHE			(),
	.SAXIGP0ARID			(),
	.SAXIGP0ARLEN			(),
	.SAXIGP0ARLOCK			(),
	.SAXIGP0ARPROT			(),
	.SAXIGP0ARQOS			(),
	.SAXIGP0ARSIZE			(),
	.SAXIGP0ARVALID			(),
	.SAXIGP0AWADDR			(),
	.SAXIGP0AWBURST			(),
	.SAXIGP0AWCACHE			(),
	.SAXIGP0AWID			(),
	.SAXIGP0AWLEN			(),
	.SAXIGP0AWLOCK			(),
	.SAXIGP0AWPROT			(),
	.SAXIGP0AWQOS			(),
	.SAXIGP0AWSIZE			(),
	.SAXIGP0AWVALID			(),
	.SAXIGP0BREADY			(),
	.SAXIGP0RREADY			(),
	.SAXIGP0WDATA			(),
	.SAXIGP0WID			(),
	.SAXIGP0WLAST			(),
	.SAXIGP0WSTRB			(),
	.SAXIGP0WVALID			(),
	.SAXIGP1ACLK			(),
	.SAXIGP1ARADDR			(),
	.SAXIGP1ARBURST			(),
	.SAXIGP1ARCACHE			(),
	.SAXIGP1ARID			(),
	.SAXIGP1ARLEN			(),
	.SAXIGP1ARLOCK			(),
	.SAXIGP1ARPROT			(),
	.SAXIGP1ARQOS			(),
	.SAXIGP1ARSIZE			(),
	.SAXIGP1ARVALID			(),
	.SAXIGP1AWADDR			(),
	.SAXIGP1AWBURST			(),
	.SAXIGP1AWCACHE			(),
	.SAXIGP1AWID			(),
	.SAXIGP1AWLEN			(),
	.SAXIGP1AWLOCK			(),
	.SAXIGP1AWPROT			(),
	.SAXIGP1AWQOS			(),
	.SAXIGP1AWSIZE			(),
	.SAXIGP1AWVALID			(),
	.SAXIGP1BREADY			(),
	.SAXIGP1RREADY			(),
	.SAXIGP1WDATA			(),
	.SAXIGP1WID			(),
	.SAXIGP1WLAST			(),
	.SAXIGP1WSTRB			(),
	.SAXIGP1WVALID			(),
	.SAXIHP0ACLK			(),
	.SAXIHP0ARADDR			(),
	.SAXIHP0ARBURST			(),
	.SAXIHP0ARCACHE			(),
	.SAXIHP0ARID			(),
	.SAXIHP0ARLEN			(),
	.SAXIHP0ARLOCK			(),
	.SAXIHP0ARPROT			(),
	.SAXIHP0ARQOS			(),
	.SAXIHP0ARSIZE			(),
	.SAXIHP0ARVALID			(),
	.SAXIHP0AWADDR			(),
	.SAXIHP0AWBURST			(),
	.SAXIHP0AWCACHE			(),
	.SAXIHP0AWID			(),
	.SAXIHP0AWLEN			(),
	.SAXIHP0AWLOCK			(),
	.SAXIHP0AWPROT			(),
	.SAXIHP0AWQOS			(),
	.SAXIHP0AWSIZE			(),
	.SAXIHP0AWVALID			(),
	.SAXIHP0BREADY			(),
	.SAXIHP0RDISSUECAP1EN		(),
	.SAXIHP0RREADY			(),
	.SAXIHP0WDATA			(),
	.SAXIHP0WID			(),
	.SAXIHP0WLAST			(),
	.SAXIHP0WRISSUECAP1EN		(),
	.SAXIHP0WSTRB			(),
	.SAXIHP0WVALID			(),
	.SAXIHP1ACLK			(),
	.SAXIHP1ARADDR			(),
	.SAXIHP1ARBURST			(),
	.SAXIHP1ARCACHE			(),
	.SAXIHP1ARID			(),
	.SAXIHP1ARLEN			(),
	.SAXIHP1ARLOCK			(),
	.SAXIHP1ARPROT			(),
	.SAXIHP1ARQOS			(),
	.SAXIHP1ARSIZE			(),
	.SAXIHP1ARVALID			(),
	.SAXIHP1AWADDR			(),
	.SAXIHP1AWBURST			(),
	.SAXIHP1AWCACHE			(),
	.SAXIHP1AWID			(),
	.SAXIHP1AWLEN			(),
	.SAXIHP1AWLOCK			(),
	.SAXIHP1AWPROT			(),
	.SAXIHP1AWQOS			(),
	.SAXIHP1AWSIZE			(),
	.SAXIHP1AWVALID			(),
	.SAXIHP1BREADY			(),
	.SAXIHP1RDISSUECAP1EN		(),
	.SAXIHP1RREADY			(),
	.SAXIHP1WDATA			(),
	.SAXIHP1WID			(),
	.SAXIHP1WLAST			(),
	.SAXIHP1WRISSUECAP1EN		(),
	.SAXIHP1WSTRB			(),
	.SAXIHP1WVALID			(),
	.SAXIHP2ACLK			(),
	.SAXIHP2ARADDR			(),
	.SAXIHP2ARBURST			(),
	.SAXIHP2ARCACHE			(),
	.SAXIHP2ARID			(),
	.SAXIHP2ARLEN			(),
	.SAXIHP2ARLOCK			(),
	.SAXIHP2ARPROT			(),
	.SAXIHP2ARQOS			(),
	.SAXIHP2ARSIZE			(),
	.SAXIHP2ARVALID			(),
	.SAXIHP2AWADDR			(),
	.SAXIHP2AWBURST			(),
	.SAXIHP2AWCACHE			(),
	.SAXIHP2AWID			(),
	.SAXIHP2AWLEN			(),
	.SAXIHP2AWLOCK			(),
	.SAXIHP2AWPROT			(),
	.SAXIHP2AWQOS			(),
	.SAXIHP2AWSIZE			(),
	.SAXIHP2AWVALID			(),
	.SAXIHP2BREADY			(),
	.SAXIHP2RDISSUECAP1EN		(),
	.SAXIHP2RREADY			(),
	.SAXIHP2WDATA			(),
	.SAXIHP2WID			(),
	.SAXIHP2WLAST			(),
	.SAXIHP2WRISSUECAP1EN		(),
	.SAXIHP2WSTRB			(),
	.SAXIHP2WVALID			(),
	.SAXIHP3ACLK			(),
	.SAXIHP3ARADDR			(),
	.SAXIHP3ARBURST			(),
	.SAXIHP3ARCACHE			(),
	.SAXIHP3ARID			(),
	.SAXIHP3ARLEN			(),
	.SAXIHP3ARLOCK			(),
	.SAXIHP3ARPROT			(),
	.SAXIHP3ARQOS			(),
	.SAXIHP3ARSIZE			(),
	.SAXIHP3ARVALID			(),
	.SAXIHP3AWADDR			(),
	.SAXIHP3AWBURST			(),
	.SAXIHP3AWCACHE			(),
	.SAXIHP3AWID			(),
	.SAXIHP3AWLEN			(),
	.SAXIHP3AWLOCK			(),
	.SAXIHP3AWPROT			(),
	.SAXIHP3AWQOS			(),
	.SAXIHP3AWSIZE			(),
	.SAXIHP3AWVALID			(),
	.SAXIHP3BREADY			(),
	.SAXIHP3RDISSUECAP1EN		(),
	.SAXIHP3RREADY			(),
	.SAXIHP3WDATA			(),
	.SAXIHP3WID			(),
	.SAXIHP3WLAST			(),
	.SAXIHP3WRISSUECAP1EN		(),
	.SAXIHP3WSTRB			(),
	.SAXIHP3WVALID			()
	);
`endif

endmodule

