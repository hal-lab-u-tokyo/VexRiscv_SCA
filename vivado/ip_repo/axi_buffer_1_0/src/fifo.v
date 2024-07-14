//
//    Copyright (C) 2024 The University of Tokyo
//    
//    File:          /ip_repo/axi_buffer_1_0/src/fifo.v
//    Project:       sakura-x-vexriscv
//    Author:        Takuya Kojima in The University of Tokyo (tkojima@hal.ipc.i.u-tokyo.ac.jp)
//    Created Date:  08-07-2024 11:37:25
//    Last Modified: 08-07-2024 11:45:52
//


module axi_buffer_fifo # (
	parameter integer DATA_WIDTH = 8,
	parameter integer DEPTH = 256
) (
	input wire clk,
	input wire reset_n,
	// input channel
	input wire [DATA_WIDTH-1:0] i_data,
	input wire i_write_enable,
	output wire o_full,

	// output channel
	output wire [DATA_WIDTH-1:0] o_data,
	input wire i_read_enable,
	output wire o_empty,

	output wire [$clog2(DEPTH):0] o_data_count
);

	reg [DATA_WIDTH-1:0] ram [0:DEPTH-1];
	reg [$clog2(DEPTH)-1:0] r_read_addr, r_write_addr;
	reg [$clog2(DEPTH):0] r_count;

	// control signals
	wire w_enqueue, w_dequeue;
	assign w_dequeue = i_read_enable & !o_empty;
	assign w_enqueue = i_write_enable & (!o_full | i_read_enable);


	// write address control
	always @(posedge clk or negedge reset_n) begin
		if (!reset_n) begin
			r_write_addr <= 0;
		end else begin
			if (w_enqueue) begin
				if (r_write_addr == DEPTH-1) begin
					r_write_addr <= 0;
				end else begin
					r_write_addr <= r_write_addr + 1;
				end
			end
		end
	end

	// write control
	integer  i;
	always @(posedge clk or negedge reset_n) begin
		if (!reset_n) begin
			for (i = 0; i < DEPTH; i = i + 1) begin
				ram[i] <= 0;
			end
		end else if (w_enqueue) begin
			ram[r_write_addr] <= i_data;
		end
	end

	// read address control
	always @(posedge clk or negedge reset_n) begin
		if (!reset_n) begin
			r_read_addr <= 0;
		end else begin
			if (w_dequeue) begin
				if (r_read_addr == DEPTH-1) begin
					r_read_addr <= 0;
				end else begin
					r_read_addr <= r_read_addr + 1;
				end
			end
		end
	end

	// data count control
	always @(posedge clk or negedge reset_n) begin
		if (!reset_n) begin
			r_count <= 0;
		end else begin
			if (!o_full & i_write_enable & !w_dequeue) begin
				// only write, i.e, + 1
				r_count <= r_count + 1;
			end else if (w_dequeue & !i_write_enable) begin
				// only read, i.e, - 1
				r_count <= r_count - 1;
			end
			// other cases, keep the current value
		end
	end

	// status output and read data
	assign o_full = (r_count == DEPTH);
	assign o_empty = (r_count == 0);
	assign o_data = ~o_empty ? ram[r_read_addr] : 0;
	assign o_data_count = r_count;

endmodule