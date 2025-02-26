//
//    Copyright (C) 2024 The University of Tokyo
//    
//    File:          /vivado/ip_repo/axi_lfsr_1_0/src/LFSR.v
//    Project:       sakura-x-vexriscv
//    Author:        Takuya Kojima in The University of Tokyo (tkojima@hal.ipc.i.u-tokyo.ac.jp)
//    Created Date:  07-07-2024 21:13:48
//    Last Modified: 26-02-2025 09:41:50

module LFSR #(
  parameter WIDTH = 32
) (
  input clk,
  input reset_n,
  input [WIDTH-1:0] seed,
  output [WIDTH-1:0] rand_out
);
	integer i;
	reg [WIDTH-1:0] r_lfsr;

	localparam MAX_WIDTH = 32;
	function XOR_TAPS;
		input [MAX_WIDTH-1:0] lfsr;
		begin
			case (WIDTH)
				4:
					XOR_TAPS = lfsr[3] ^ lfsr[2];
				8:
					XOR_TAPS = lfsr[7] ^ lfsr[5] ^ lfsr[4] ^ lfsr[3];
				16:
					XOR_TAPS = lfsr[15] ^ lfsr[14] ^ lfsr[12] ^ lfsr[3];
				32:
					XOR_TAPS = lfsr[31] ^ lfsr[21] ^ lfsr[1] ^ lfsr[0];
			endcase
		end
	endfunction

	wire w_xor_taps = XOR_TAPS(r_lfsr);

	always @(posedge clk or negedge reset_n) begin
		if (!reset_n) begin
			r_lfsr <= seed;
		end else begin
			r_lfsr <= {r_lfsr[WIDTH-2:0], w_xor_taps};
		end
	end

	assign rand_out = r_lfsr;

endmodule