/*
 * ice40_serdes_dff.v
 *
 * vim: ts=4 sw=4
 *
 * Copyright (C) 2020  Sylvain Munaut <tnt@246tNt.com>
 * SPDX-License-Identifier: CERN-OHL-P-2.0
 */

`default_nettype none

module ice40_serdes_dff #(
	parameter integer NEG = 0,
	parameter integer ENA = 0,
	parameter integer RST = 0,
	parameter integer SERDES_GRP = -1,
	parameter SERDES_ATTR = "",
	parameter BEL = ""
)(
	input  wire d,
	output wire q,
	input  wire e,
	input  wire r,
	input  wire c
);
	parameter TYPE = (RST ? 4 : 0) | (ENA ? 2 : 0) | (NEG ? 1 : 0);

	generate
		if (TYPE == 0)			// Simple
			(* BEL=BEL, SERDES_GRP=SERDES_GRP, SERDES_ATTR=SERDES_ATTR *)
			(* dont_touch, keep *)
			SB_DFF dff_I (
				.D(d),
				.Q(q),
				.C(c)
			);

		else if (TYPE == 1)		// NEG
			(* BEL=BEL, SERDES_GRP=SERDES_GRP, SERDES_ATTR=SERDES_ATTR *)
			(* dont_touch, keep *)
			SB_DFFN dff_I (
				.D(d),
				.Q(q),
				.C(c)
			);

		else if (TYPE == 2)		//     ENA
			(* BEL=BEL, SERDES_GRP=SERDES_GRP, SERDES_ATTR=SERDES_ATTR *)
			(* dont_touch, keep *)
			SB_DFFE dff_I (
				.D(d),
				.Q(q),
				.E(e),
				.C(c)
			);

		else if (TYPE == 3)		// NEG ENA
			(* BEL=BEL, SERDES_GRP=SERDES_GRP, SERDES_ATTR=SERDES_ATTR *)
			(* dont_touch, keep *)
			SB_DFFNE dff_I (
				.D(d),
				.Q(q),
				.E(e),
				.C(c)
			);

		else if (TYPE == 4)		//         RST
			(* BEL=BEL, SERDES_GRP=SERDES_GRP, SERDES_ATTR=SERDES_ATTR *)
			(* dont_touch, keep *)
			SB_DFFR dff_I (
				.D(d),
				.Q(q),
				.R(r),
				.C(c)
			);

		else if (TYPE == 5)		// NEG     RST
			(* BEL=BEL, SERDES_GRP=SERDES_GRP, SERDES_ATTR=SERDES_ATTR *)
			(* dont_touch, keep *)
			SB_DFFNR dff_I (
				.D(d),
				.Q(q),
				.R(r),
				.C(c)
			);

		else if (TYPE == 6)		//     ENA RST
			(* BEL=BEL, SERDES_GRP=SERDES_GRP, SERDES_ATTR=SERDES_ATTR *)
			(* dont_touch, keep *)
			SB_DFFER dff_I (
				.D(d),
				.Q(q),
				.E(e),
				.R(r),
				.C(c)
			);

		else if (TYPE == 7)		// NEG ENA RST
			(* BEL=BEL, SERDES_GRP=SERDES_GRP, SERDES_ATTR=SERDES_ATTR *)
			(* dont_touch, keep *)
			SB_DFFNER dff_I (
				.D(d),
				.Q(q),
				.E(e),
				.R(r),
				.C(c)
			);

	endgenerate

endmodule
