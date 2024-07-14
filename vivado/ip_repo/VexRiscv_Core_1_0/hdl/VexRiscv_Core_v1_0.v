//
//    Copyright (C) 2024 The University of Tokyo
//    
//    File:          /vivado/ip_repo/VexRiscv_Core_1_0/hdl/VexRiscv_Core_v1_0.v
//    Project:       sakura-x-vexriscv
//    Author:        Takuya Kojima in The University of Tokyo (tkojima@hal.ipc.i.u-tokyo.ac.jp)
//    Created Date:  14-07-2024 23:27:56
//    Last Modified: 14-07-2024 23:27:57
//

`timescale 1 ns / 1 ps

module VexRiscv_Core_v1_0 #
(
	// Users to add parameters here

	// User parameters ends
	// Do not modify the parameters beyond this line


	// Parameters of Axi Slave Bus Interface S_CTRL_AXI
	parameter integer C_S_CTRL_AXI_DATA_WIDTH	= 32,
	parameter integer C_S_CTRL_AXI_ADDR_WIDTH	= 4,

	// Parameters of Axi Master Bus Interface M_DATA_AXI
	parameter  C_M_DATA_AXI_TARGET_SLAVE_BASE_ADDR	= 32'h40000000,
	parameter integer C_M_DATA_AXI_BURST_LEN	= 16,
	parameter integer C_M_DATA_AXI_ID_WIDTH	= 1,
	parameter integer C_M_DATA_AXI_ADDR_WIDTH	= 32,
	parameter integer C_M_DATA_AXI_DATA_WIDTH	= 32,
	parameter integer C_M_DATA_AXI_AWUSER_WIDTH	= 0,
	parameter integer C_M_DATA_AXI_ARUSER_WIDTH	= 0,
	parameter integer C_M_DATA_AXI_WUSER_WIDTH	= 0,
	parameter integer C_M_DATA_AXI_RUSER_WIDTH	= 0,
	parameter integer C_M_DATA_AXI_BUSER_WIDTH	= 0,

	// Parameters of Axi Master Bus Interface M_INST_AXI
	parameter  C_M_INST_AXI_TARGET_SLAVE_BASE_ADDR	= 32'h40000000,
	parameter integer C_M_INST_AXI_BURST_LEN	= 16,
	parameter integer C_M_INST_AXI_ID_WIDTH	= 1,
	parameter integer C_M_INST_AXI_ADDR_WIDTH	= 32,
	parameter integer C_M_INST_AXI_DATA_WIDTH	= 32,
	parameter integer C_M_INST_AXI_AWUSER_WIDTH	= 0,
	parameter integer C_M_INST_AXI_ARUSER_WIDTH	= 0,
	parameter integer C_M_INST_AXI_WUSER_WIDTH	= 0,
	parameter integer C_M_INST_AXI_RUSER_WIDTH	= 0,
	parameter integer C_M_INST_AXI_BUSER_WIDTH	= 0
)
(
	// Users to add ports here

	// User ports ends
	// Do not modify the ports beyond this line


	// Ports of Axi Slave Bus Interface S_CTRL_AXI
	input wire  s_ctrl_axi_aclk,
	input wire  s_ctrl_axi_aresetn,
	input wire [C_S_CTRL_AXI_ADDR_WIDTH-1 : 0] s_ctrl_axi_awaddr,
	input wire [2 : 0] s_ctrl_axi_awprot,
	input wire  s_ctrl_axi_awvalid,
	output wire  s_ctrl_axi_awready,
	input wire [C_S_CTRL_AXI_DATA_WIDTH-1 : 0] s_ctrl_axi_wdata,
	input wire [(C_S_CTRL_AXI_DATA_WIDTH/8)-1 : 0] s_ctrl_axi_wstrb,
	input wire  s_ctrl_axi_wvalid,
	output wire  s_ctrl_axi_wready,
	output wire [1 : 0] s_ctrl_axi_bresp,
	output wire  s_ctrl_axi_bvalid,
	input wire  s_ctrl_axi_bready,
	input wire [C_S_CTRL_AXI_ADDR_WIDTH-1 : 0] s_ctrl_axi_araddr,
	input wire [2 : 0] s_ctrl_axi_arprot,
	input wire  s_ctrl_axi_arvalid,
	output wire  s_ctrl_axi_arready,
	output wire [C_S_CTRL_AXI_DATA_WIDTH-1 : 0] s_ctrl_axi_rdata,
	output wire [1 : 0] s_ctrl_axi_rresp,
	output wire  s_ctrl_axi_rvalid,
	input wire  s_ctrl_axi_rready,

	// Ports of Axi Master Bus Interface M_INST_AXI
	input wire  m_inst_axi_aclk,
	input wire  m_inst_axi_aresetn,
	output wire [C_M_INST_AXI_ID_WIDTH-1 : 0] m_inst_axi_awid,
	output wire [C_M_INST_AXI_ADDR_WIDTH-1 : 0] m_inst_axi_awaddr,
	output wire [7 : 0] m_inst_axi_awlen,
	output wire [2 : 0] m_inst_axi_awsize,
	output wire [1 : 0] m_inst_axi_awburst,
	output wire  m_inst_axi_awlock,
	output wire [3 : 0] m_inst_axi_awcache,
	output wire [2 : 0] m_inst_axi_awprot,
	output wire [3 : 0] m_inst_axi_awqos,
	output wire [C_M_INST_AXI_AWUSER_WIDTH-1 : 0] m_inst_axi_awuser,
	output wire  m_inst_axi_awvalid,
	input wire  m_inst_axi_awready,
	output wire [C_M_INST_AXI_DATA_WIDTH-1 : 0] m_inst_axi_wdata,
	output wire [C_M_INST_AXI_DATA_WIDTH/8-1 : 0] m_inst_axi_wstrb,
	output wire  m_inst_axi_wlast,
	output wire [C_M_INST_AXI_WUSER_WIDTH-1 : 0] m_inst_axi_wuser,
	output wire  m_inst_axi_wvalid,
	input wire  m_inst_axi_wready,
	input wire [C_M_INST_AXI_ID_WIDTH-1 : 0] m_inst_axi_bid,
	input wire [1 : 0] m_inst_axi_bresp,
	input wire [C_M_INST_AXI_BUSER_WIDTH-1 : 0] m_inst_axi_buser,
	input wire  m_inst_axi_bvalid,
	output wire  m_inst_axi_bready,
	output wire [C_M_INST_AXI_ID_WIDTH-1 : 0] m_inst_axi_arid,
	output wire [C_M_INST_AXI_ADDR_WIDTH-1 : 0] m_inst_axi_araddr,
	output wire [7 : 0] m_inst_axi_arlen,
	output wire [2 : 0] m_inst_axi_arsize,
	output wire [1 : 0] m_inst_axi_arburst,
	output wire  m_inst_axi_arlock,
	output wire [3 : 0] m_inst_axi_arcache,
	output wire [2 : 0] m_inst_axi_arprot,
	output wire [3 : 0] m_inst_axi_arqos,
	output wire [C_M_INST_AXI_ARUSER_WIDTH-1 : 0] m_inst_axi_aruser,
	output wire  m_inst_axi_arvalid,
	input wire  m_inst_axi_arready,
	input wire [C_M_INST_AXI_ID_WIDTH-1 : 0] m_inst_axi_rid,
	input wire [C_M_INST_AXI_DATA_WIDTH-1 : 0] m_inst_axi_rdata,
	input wire [1 : 0] m_inst_axi_rresp,
	input wire  m_inst_axi_rlast,
	input wire [C_M_INST_AXI_RUSER_WIDTH-1 : 0] m_inst_axi_ruser,
	input wire  m_inst_axi_rvalid,
	output wire  m_inst_axi_rready,

	// Ports of Axi Master Bus Interface M_DATA_AXI
	input wire  m_data_axi_aclk,
	input wire  m_data_axi_aresetn,
	output wire [C_M_DATA_AXI_ID_WIDTH-1 : 0] m_data_axi_awid,
	output wire [C_M_DATA_AXI_ADDR_WIDTH-1 : 0] m_data_axi_awaddr,
	output wire [7 : 0] m_data_axi_awlen,
	output wire [2 : 0] m_data_axi_awsize,
	output wire [1 : 0] m_data_axi_awburst,
	output wire  m_data_axi_awlock,
	output wire [3 : 0] m_data_axi_awcache,
	output wire [2 : 0] m_data_axi_awprot,
	output wire [3 : 0] m_data_axi_awqos,
	output wire [C_M_DATA_AXI_AWUSER_WIDTH-1 : 0] m_data_axi_awuser,
	output wire  m_data_axi_awvalid,
	input wire  m_data_axi_awready,
	output wire [C_M_DATA_AXI_DATA_WIDTH-1 : 0] m_data_axi_wdata,
	output wire [C_M_DATA_AXI_DATA_WIDTH/8-1 : 0] m_data_axi_wstrb,
	output wire  m_data_axi_wlast,
	output wire [C_M_DATA_AXI_WUSER_WIDTH-1 : 0] m_data_axi_wuser,
	output wire  m_data_axi_wvalid,
	input wire  m_data_axi_wready,
	input wire [C_M_DATA_AXI_ID_WIDTH-1 : 0] m_data_axi_bid,
	input wire [1 : 0] m_data_axi_bresp,
	input wire [C_M_DATA_AXI_BUSER_WIDTH-1 : 0] m_data_axi_buser,
	input wire  m_data_axi_bvalid,
	output wire  m_data_axi_bready,
	output wire [C_M_DATA_AXI_ID_WIDTH-1 : 0] m_data_axi_arid,
	output wire [C_M_DATA_AXI_ADDR_WIDTH-1 : 0] m_data_axi_araddr,
	output wire [7 : 0] m_data_axi_arlen,
	output wire [2 : 0] m_data_axi_arsize,
	output wire [1 : 0] m_data_axi_arburst,
	output wire  m_data_axi_arlock,
	output wire [3 : 0] m_data_axi_arcache,
	output wire [2 : 0] m_data_axi_arprot,
	output wire [3 : 0] m_data_axi_arqos,
	output wire [C_M_DATA_AXI_ARUSER_WIDTH-1 : 0] m_data_axi_aruser,
	output wire  m_data_axi_arvalid,
	input wire  m_data_axi_arready,
	input wire [C_M_DATA_AXI_ID_WIDTH-1 : 0] m_data_axi_rid,
	input wire [C_M_DATA_AXI_DATA_WIDTH-1 : 0] m_data_axi_rdata,
	input wire [1 : 0] m_data_axi_rresp,
	input wire  m_data_axi_rlast,
	input wire [C_M_DATA_AXI_RUSER_WIDTH-1 : 0] m_data_axi_ruser,
	input wire  m_data_axi_rvalid,
	output wire  m_data_axi_rready
);

	wire core_reset_n;
	wire w_ext_reset_n, w_ext_interrupt;
	assign core_reset_n = m_inst_axi_aresetn & m_data_axi_aresetn & w_ext_reset_n;

	// Instantiation of Axi Bus Interface S_CTRL_AXI
	VexRiscv_Core_v1_0_S_CTRL_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_S_CTRL_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S_CTRL_AXI_ADDR_WIDTH)
	) VexRiscv_Core_v1_0_S_CTRL_AXI_inst (
		.ext_reset_n(w_ext_reset_n),
		.ext_interrupt(w_ext_interrupt),
		.S_AXI_ACLK(s_ctrl_axi_aclk),
		.S_AXI_ARESETN(s_ctrl_axi_aresetn),
		.S_AXI_AWADDR(s_ctrl_axi_awaddr),
		.S_AXI_AWPROT(s_ctrl_axi_awprot),
		.S_AXI_AWVALID(s_ctrl_axi_awvalid),
		.S_AXI_AWREADY(s_ctrl_axi_awready),
		.S_AXI_WDATA(s_ctrl_axi_wdata),
		.S_AXI_WSTRB(s_ctrl_axi_wstrb),
		.S_AXI_WVALID(s_ctrl_axi_wvalid),
		.S_AXI_WREADY(s_ctrl_axi_wready),
		.S_AXI_BRESP(s_ctrl_axi_bresp),
		.S_AXI_BVALID(s_ctrl_axi_bvalid),
		.S_AXI_BREADY(s_ctrl_axi_bready),
		.S_AXI_ARADDR(s_ctrl_axi_araddr),
		.S_AXI_ARPROT(s_ctrl_axi_arprot),
		.S_AXI_ARVALID(s_ctrl_axi_arvalid),
		.S_AXI_ARREADY(s_ctrl_axi_arready),
		.S_AXI_RDATA(s_ctrl_axi_rdata),
		.S_AXI_RRESP(s_ctrl_axi_rresp),
		.S_AXI_RVALID(s_ctrl_axi_rvalid),
		.S_AXI_RREADY(s_ctrl_axi_rready)
	);

	VexRiscvCore core0 (
		.timerInterrupt(1'b0),
		.externalInterrupt(w_ext_interrupt),
		.softwareInterrupt(1'b0),
		.M_INST_AXI_ar_valid(m_inst_axi_arvalid),
		.M_INST_AXI_ar_ready(m_inst_axi_arready),
		.M_INST_AXI_ar_payload_addr(m_inst_axi_araddr),
		.M_INST_AXI_ar_payload_id(m_inst_axi_arid),
		.M_INST_AXI_ar_payload_region(),
		.M_INST_AXI_ar_payload_len(m_inst_axi_arlen),
		.M_INST_AXI_ar_payload_size(m_inst_axi_arsize),
		.M_INST_AXI_ar_payload_burst(m_inst_axi_arburst),
		.M_INST_AXI_ar_payload_lock(m_inst_axi_arlock),
		.M_INST_AXI_ar_payload_cache(m_inst_axi_arcache),
		.M_INST_AXI_ar_payload_qos(m_inst_axi_arqos),
		.M_INST_AXI_ar_payload_prot(m_inst_axi_arprot),
		.M_INST_AXI_r_valid(m_inst_axi_rvalid),
		.M_INST_AXI_r_ready(m_inst_axi_rready),
		.M_INST_AXI_r_payload_data(m_inst_axi_rdata),
		.M_INST_AXI_r_payload_id(m_inst_axi_rid),
		.M_INST_AXI_r_payload_resp(m_inst_axi_rresp),
		.M_INST_AXI_r_payload_last(m_inst_axi_rlast),
		.M_DATA_AXI_aw_valid(m_data_axi_awvalid),
		.M_DATA_AXI_aw_ready(m_data_axi_awready),
		.M_DATA_AXI_aw_payload_addr(m_data_axi_awaddr),
		.M_DATA_AXI_aw_payload_id(m_data_axi_awid),
		.M_DATA_AXI_aw_payload_region(),
		.M_DATA_AXI_aw_payload_len(m_data_axi_awlen),
		.M_DATA_AXI_aw_payload_size(m_data_axi_awsize),
		.M_DATA_AXI_aw_payload_burst(m_data_axi_awburst),
		.M_DATA_AXI_aw_payload_lock(m_data_axi_awlock),
		.M_DATA_AXI_aw_payload_cache(m_data_axi_awcache),
		.M_DATA_AXI_aw_payload_qos(m_data_axi_awqos),
		.M_DATA_AXI_aw_payload_prot(m_data_axi_awprot),
		.M_DATA_AXI_w_valid(m_data_axi_wvalid),
		.M_DATA_AXI_w_ready(m_data_axi_wready),
		.M_DATA_AXI_w_payload_data(m_data_axi_wdata),
		.M_DATA_AXI_w_payload_strb(m_data_axi_wstrb),
		.M_DATA_AXI_w_payload_last(m_data_axi_wlast),
		.M_DATA_AXI_b_valid(m_data_axi_bvalid),
		.M_DATA_AXI_b_ready(m_data_axi_bready),
		.M_DATA_AXI_b_payload_id(m_data_axi_bid),
		.M_DATA_AXI_b_payload_resp(m_data_axi_bresp),
		.M_DATA_AXI_ar_valid(m_data_axi_arvalid),
		.M_DATA_AXI_ar_ready(m_data_axi_arready),
		.M_DATA_AXI_ar_payload_addr(m_data_axi_araddr),
		.M_DATA_AXI_ar_payload_id(m_data_axi_arid),
		.M_DATA_AXI_ar_payload_region(),
		.M_DATA_AXI_ar_payload_len(m_data_axi_arlen),
		.M_DATA_AXI_ar_payload_size(m_data_axi_arsize),
		.M_DATA_AXI_ar_payload_burst(m_data_axi_arburst),
		.M_DATA_AXI_ar_payload_lock(m_data_axi_arlock),
		.M_DATA_AXI_ar_payload_cache(m_data_axi_arcache),
		.M_DATA_AXI_ar_payload_qos(m_data_axi_arqos),
		.M_DATA_AXI_ar_payload_prot(m_data_axi_arprot),
		.M_DATA_AXI_r_valid(m_data_axi_rvalid),
		.M_DATA_AXI_r_ready(m_data_axi_rready),
		.M_DATA_AXI_r_payload_data(m_data_axi_rdata),
		.M_DATA_AXI_r_payload_id(m_data_axi_rid),
		.M_DATA_AXI_r_payload_resp(m_data_axi_rresp),
		.M_DATA_AXI_r_payload_last(m_data_axi_rlast),
		.clk(m_inst_axi_aclk),
		.reset(~core_reset_n)
	);

	// aw,w channel for INST_AXI not used because of read only
	assign m_inst_axi_awid = 0;
	assign m_inst_axi_awaddr = 0;
	assign m_inst_axi_awlen = 0;
	assign m_inst_axi_awsize = 0;
	assign m_inst_axi_awburst = 0;
	assign m_inst_axi_awlock = 0;
	assign m_inst_axi_awcache = 0;
	assign m_inst_axi_awprot = 0;
	assign m_inst_axi_awqos = 0;
	assign m_inst_axi_awuser = 0;
	assign m_inst_axi_awvalid = 0;
	assign m_inst_axi_wdata = 0;
	assign m_inst_axi_wstrb = 0;
	assign m_inst_axi_wlast = 0;
	assign m_inst_axi_wuser = 0;
	assign m_inst_axi_wvalid = 0;
	assign m_inst_axi_bready = 1;
	assign m_inst_axi_aruser = 0;

	assign m_data_axi_awuser = 0;
	assign m_data_axi_wuser = 0;
	assign m_data_axi_aruser = 0;


endmodule
