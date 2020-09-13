/*
 * ice40_rgb_wb.v
 *
 * vim: ts=4 sw=4
 *
 * Wishbone wrapper to use the SB_LEDDA_IP & SB_RGBA_DRV hard macro
 * a bit more easily
 *
 * Copyright (C) 2020  Sylvain Munaut <tnt@246tNt.com>
 * SPDX-License-Identifier: CERN-OHL-P-2.0
 */

`default_nettype none

module ice40_rgb_wb #(
	parameter CURRENT_MODE = "0b1",
	parameter RGB0_CURRENT = "0b000001",
	parameter RGB1_CURRENT = "0b000001",
	parameter RGB2_CURRENT = "0b000001"
)(
	// RGB pad
	output wire [ 2:0] pad_rgb,

	// Wishbone interface
	input  wire [ 4:0] wb_addr,
	output wire [31:0] wb_rdata,
	input  wire [31:0] wb_wdata,
	input  wire        wb_we,
	input  wire        wb_cyc,
	output wire        wb_ack,

	// Common
	input  wire clk,
	input  wire rst
);

	// Signals
	// -------

	reg  [4:0] led_ctrl;
	wire [2:0] pwm_rgb;


	// PWM IP
	// ------

	SB_LEDDA_IP led_I (
		.LEDDCS   (wb_addr[4] & wb_we),
		.LEDDCLK  (clk),
		.LEDDDAT7 (wb_wdata[7]),
		.LEDDDAT6 (wb_wdata[6]),
		.LEDDDAT5 (wb_wdata[5]),
		.LEDDDAT4 (wb_wdata[4]),
		.LEDDDAT3 (wb_wdata[3]),
		.LEDDDAT2 (wb_wdata[2]),
		.LEDDDAT1 (wb_wdata[1]),
		.LEDDDAT0 (wb_wdata[0]),
		.LEDDADDR3(wb_addr[3]),
		.LEDDADDR2(wb_addr[2]),
		.LEDDADDR1(wb_addr[1]),
		.LEDDADDR0(wb_addr[0]),
		.LEDDDEN  (wb_cyc),
		.LEDDEXE  (led_ctrl[1]),
		.PWMOUT0  (pwm_rgb[0]),
		.PWMOUT1  (pwm_rgb[1]),
		.PWMOUT2  (pwm_rgb[2]),
		.LEDDON   ()
	);


	// CC Driver
	// ---------

	SB_RGBA_DRV #(
		.CURRENT_MODE(CURRENT_MODE),
		.RGB0_CURRENT(RGB0_CURRENT),
		.RGB1_CURRENT(RGB1_CURRENT),
		.RGB2_CURRENT(RGB2_CURRENT)
	) rgb_drv_I (
		.RGBLEDEN(led_ctrl[2]),
		.RGB0PWM (pwm_rgb[0]),
		.RGB1PWM (pwm_rgb[1]),
		.RGB2PWM (pwm_rgb[2]),
		.CURREN  (led_ctrl[3]),
		.RGB0    (pad_rgb[0]),
		.RGB1    (pad_rgb[1]),
		.RGB2    (pad_rgb[2])
	);


	// Bus interface
	// -------------

	always @(posedge clk or posedge rst)
		if (rst)
			led_ctrl <= 0;
		else if (wb_cyc & ~wb_addr[4] & wb_we)
			led_ctrl <= wb_wdata[4:0];

	assign wb_rdata = 32'h00000000;
	assign wb_ack = wb_cyc;

endmodule // ice40_rgb_wb
