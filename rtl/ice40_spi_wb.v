/*
 * ice40_spi_wb.v
 *
 * vim: ts=4 sw=4
 *
 * Wishbone wrapper to use the SB_SPI hardmacro a bit more easily
 *
 * Copyright (C) 2020  Sylvain Munaut <tnt@246tNt.com>
 * SPDX-License-Identifier: CERN-OHL-P-2.0
 */

`default_nettype none

module ice40_spi_wb #(
	parameter integer N_CS = 1,
	parameter integer WITH_IOB = 1,
	parameter integer UNIT = 0,		// Unit 0 or 1

	// auto
	parameter integer H = N_CS - 1
)(
	// IO
		// IOBs included
	inout  wire        pad_mosi,
	inout  wire        pad_miso,
	inout  wire        pad_clk,
	output wire [ H:0] pad_csn,

		// Raw signals
	input  wire        sio_mosi_i,
	output wire        sio_mosi_o,
	output wire        sio_mosi_oe,

	input  wire        sio_miso_i,
	output wire        sio_miso_o,
	output wire        sio_miso_oe,

	input  wire        sio_clk_i,
	output wire        sio_clk_o,
	output wire        sio_clk_oe,

	output wire [ H:0] sio_csn_o,
	output wire [ H:0] sio_csn_oe,

	// Wishbone interface
	input  wire [ 3:0] wb_addr,
	output wire [31:0] wb_rdata,
	input  wire [31:0] wb_wdata,
	input  wire        wb_we,
	input  wire        wb_cyc,
	output wire        wb_ack,

	// Aux signals
	output wire irq,
	output wire wakeup,

	// Common
	input  wire clk,
	input  wire rst
);

	// Signals
	// -------

	wire [7:0] sb_addr;
	wire [7:0] sb_di;
	wire [7:0] sb_do;
	wire       sb_rw;
	wire       sb_stb;
	wire       sb_ack;

	wire [3:0] sio_csn_o_i;
	wire [3:0] sio_csn_oe_i;


	// Hard block
	// ----------

`ifndef SIM
	SB_SPI #(
		.BUS_ADDR74(UNIT ? "0b0010" : "0b0000")
	) spi_I (
		.SBCLKI  (clk),
		.SBRWI   (sb_rw),
		.SBSTBI  (sb_stb),
		.SBADRI7 (sb_addr[7]),
		.SBADRI6 (sb_addr[6]),
		.SBADRI5 (sb_addr[5]),
		.SBADRI4 (sb_addr[4]),
		.SBADRI3 (sb_addr[3]),
		.SBADRI2 (sb_addr[2]),
		.SBADRI1 (sb_addr[1]),
		.SBADRI0 (sb_addr[0]),
		.SBDATI7 (sb_di[7]),
		.SBDATI6 (sb_di[6]),
		.SBDATI5 (sb_di[5]),
		.SBDATI4 (sb_di[4]),
		.SBDATI3 (sb_di[3]),
		.SBDATI2 (sb_di[2]),
		.SBDATI1 (sb_di[1]),
		.SBDATI0 (sb_di[0]),
		.MI      (sio_miso_i),
		.SI      (sio_mosi_i),
		.SCKI    (sio_clk_i),
		.SCSNI   (1'b1),
		.SBDATO7 (sb_do[7]),
		.SBDATO6 (sb_do[6]),
		.SBDATO5 (sb_do[5]),
		.SBDATO4 (sb_do[4]),
		.SBDATO3 (sb_do[3]),
		.SBDATO2 (sb_do[2]),
		.SBDATO1 (sb_do[1]),
		.SBDATO0 (sb_do[0]),
		.SBACKO  (sb_ack),
		.SPIIRQ  (irq),
		.SPIWKUP (wakeup),
		.SO      (sio_miso_o),
		.SOE     (sio_miso_oe),
		.MO      (sio_mosi_o),
		.MOE     (sio_mosi_oe),
		.SCKO    (sio_clk_o),
		.SCKOE   (sio_clk_oe),
		.MCSNO3  (sio_csn_o_i[3]),
		.MCSNO2  (sio_csn_o_i[2]),
		.MCSNO1  (sio_csn_o_i[1]),
		.MCSNO0  (sio_csn_o_i[0]),
		.MCSNOE3 (sio_csn_oe_i[3]),
		.MCSNOE2 (sio_csn_oe_i[2]),
		.MCSNOE1 (sio_csn_oe_i[1]),
		.MCSNOE0 (sio_csn_oe_i[0])
	);
`else
	assign sb_ack = sb_stb;
	assign sb_do  = 8'h00;
`endif


	// IOB (if needed)
	// ---------------

	assign sio_csn_o  = sio_csn_o_i[H:0];
	assign sio_csn_oe = sio_csn_oe_i[H:0];

	generate
		if (WITH_IOB) begin

			// IOB for main signals
			SB_IO #(
				.PIN_TYPE(6'b101001),
				.PULLUP(1'b1)
			) spi_io_I[2:0] (
				.PACKAGE_PIN  ({pad_mosi,    pad_miso,    pad_clk   }),
				.OUTPUT_ENABLE({sio_mosi_oe, sio_miso_oe, sio_clk_oe}),
				.D_OUT_0      ({sio_mosi_o,  sio_miso_o,  sio_clk_o }),
				.D_IN_0       ({sio_mosi_i,  sio_miso_i,  sio_clk_i })
			);

			// Bypass OE for CS_n lines
			assign pad_csn  = sio_csn_o_i[H:0];
		end
	endgenerate


	// Bus interface
	// -------------

	assign sb_addr  = { (UNIT ? 4'h2 : 4'h0), wb_addr };
	assign sb_di    = wb_wdata[7:0];
	assign sb_rw    = wb_we;
	assign sb_stb   = wb_cyc;

	assign wb_rdata = { 24'h0000, wb_cyc ? sb_do : 8'h00 };
	assign wb_ack   = sb_ack;

endmodule // ice40_spi_wb
