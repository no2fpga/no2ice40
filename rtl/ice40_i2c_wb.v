/*
 * ice40_i2c_wb.v
 *
 * vim: ts=4 sw=4
 *
 * Wishbone wrapper to use the SB_I2C hardmacro a bit more easily
 *
 * Copyright (C) 2020  Sylvain Munaut <tnt@246tNt.com>
 * SPDX-License-Identifier: CERN-OHL-P-2.0
 */

`default_nettype none

module ice40_i2c_wb #(
	parameter integer WITH_IOB = 1,
	parameter integer UNIT = 0		// Unit 0 or 1
)(
	// IO
		// IOBs included
	inout  wire        i2c_scl,
	inout  wire        i2c_sda,

		// Raw signals
	input  wire        i2c_scl_i,
	output wire        i2c_scl_o,
	output wire        i2c_scl_oe,

	input  wire        i2c_sda_i,
	output wire        i2c_sda_o,
	output wire        i2c_sda_oe,

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


	// Hard block
	// ----------

`ifndef SIM
	(* SCL_INPUT_FILTERED=1 *)
	SB_I2C #(
		.BUS_ADDR74(UNIT ? "0b0011" : "0b0001")
	) i2c_I (
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
		.SCLI    (i2c_scl_i),
		.SDAI    (i2c_sda_i),
		.SBDATO7 (sb_do[7]),
		.SBDATO6 (sb_do[6]),
		.SBDATO5 (sb_do[5]),
		.SBDATO4 (sb_do[4]),
		.SBDATO3 (sb_do[3]),
		.SBDATO2 (sb_do[2]),
		.SBDATO1 (sb_do[1]),
		.SBDATO0 (sb_do[0]),
		.SBACKO  (sb_ack),
		.I2CIRQ  (irq),
		.I2CWKUP (wakeup),
		.SCLO    (i2c_scl_o),
		.SCLOE   (i2c_scl_oe),
		.SDAO    (i2c_sda_o),
		.SDAOE   (i2c_sda_oe)
	);
`else
	assign sb_ack = sb_stb;
	assign sb_do  = 8'h00;
`endif


	// IOB (if needed)
	// ---------------

	generate
		if (WITH_IOB) begin

			SB_IO #(
				.PIN_TYPE(6'b101001),
				.PULLUP(1'b1)
			) i2c_io_I[1:0] (
				.PACKAGE_PIN  ({i2c_scl,    i2c_sda   }),
				.OUTPUT_ENABLE({i2c_scl_oe, i2c_sda_oe}),
				.D_OUT_0      ({i2c_scl_o,  i2c_sda_o }),
				.D_IN_0       ({i2c_scl_i,  i2c_sda_i })
			);

		end
	endgenerate


	// Bus interface
	// -------------

	assign sb_addr  = { (UNIT ? 4'h3 : 4'h1), wb_addr };
	assign sb_di    = wb_wdata[7:0];
	assign sb_rw    = wb_we;
	assign sb_stb   = wb_cyc;

	assign wb_rdata = { 24'h0000, wb_cyc ? sb_do : 8'h00 };
	assign wb_ack   = sb_ack;

endmodule // ice40_i2c_wb
