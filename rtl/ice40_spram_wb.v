/*
 * ice40_spram_wb.v
 *
 * vim: ts=4 sw=4
 *
 * Copyright (C) 2020  Sylvain Munaut <tnt@246tNt.com>
 * SPDX-License-Identifier: CERN-OHL-P-2.0
 */

`default_nettype none

module ice40_spram_wb #(
	parameter integer AW = 14,
	parameter integer DW = 32,
	parameter integer ZERO_RDATA = 0,

	// auto
	parameter integer MW = (DW / 8)
)(
	// Wishbone interface
	input  wire [AW-1:0] wb_addr,
	output wire [DW-1:0] wb_rdata,
	input  wire [DW-1:0] wb_wdata,
	input  wire [MW-1:0] wb_wmsk,
	input  wire          wb_we,
	input  wire          wb_cyc,
	output wire          wb_ack,

	// Common
	input  wire clk,
	input  wire rst
);

	// Signals
	// -------

	genvar i;

	wire [ DW   -1:0] rdata;
	wire [(DW/4)-1:0] msk_nibble;
	wire we_i;
	reg  ack_i;


	// Glue
	// ----

	assign we_i = wb_cyc & wb_we & ~ack_i;

	always @(posedge clk or posedge rst)
		if (rst)
			ack_i <= 1'b0;
		else
			ack_i <= wb_cyc & ~ack_i;

	assign wb_ack = ack_i;


	// SPRAMs
	// ------

	generate
		// SPRAM mask is per 4 bits
		for (i=0; i<(DW/4); i=i+1)
			assign msk_nibble[i] = wb_wmsk[i/2];

		// If needed, zero rdata during inactive cycles
		if (ZERO_RDATA)
			assign wb_rdata = ack_i ? rdata : { (DW){1'b0} };
		else
			assign wb_rdata = rdata;
	endgenerate

	ice40_spram_gen #(
		.ADDR_WIDTH(AW),
		.DATA_WIDTH(DW)
	) spram_I (
		.addr(wb_addr),
		.rd_data(rdata),
		.rd_ena(1'b1),
		.wr_data(wb_wdata),
		.wr_mask(msk_nibble),
		.wr_ena(we_i),
		.clk(clk)
	);

endmodule // ice40_spram_wb
