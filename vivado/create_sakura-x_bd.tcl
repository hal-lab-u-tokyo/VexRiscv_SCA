variable design_name
set design_name main

set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

set scriptPath [file normalize [info script]]
set scriptDir [file dirname $scriptPath]

common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
current_bd_design $design_name

# add IP repo
set ip_repo_loc [file normalize [file join $scriptDir "ip_repo"]]
set src_set [current_fileset -quiet]
set current_ip_repo_paths [get_property "ip_repo_paths" $src_set]

# append
if { [lsearch -exact $current_ip_repo_paths $ip_repo_loc] == -1 } {
	# concat space separated paths
	set current_ip_repo_paths [concat $current_ip_repo_paths $ip_repo_loc]
	set_property "ip_repo_paths" $current_ip_repo_paths $src_set
}
update_ip_catalog -rebuild

# add extra constraints
set constr_set [current_fileset -quiet -constrset]
import_files -fileset $constr_set [file normalize [file join $scriptDir "gpio.xdc"]]



# update block design
set parentCell [get_bd_cells /]

# Get object for parentCell
set parentObj [get_bd_cells $parentCell]
if { $parentObj == "" } {
	catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
	return
}

# Make sure parentObj is hier blk
set parentType [get_property TYPE $parentObj]
if { $parentType ne "hier" } {
	catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
	return
}

# Save current instance; Restore later
set oldCurInst [current_bd_instance .]

# create ports
set k_header [ create_bd_port -dir O -from 9 -to 0 k_header ]
set k_dipsw [ create_bd_port -dir I -from 7 -to 0 k_dipsw ]

# change PLL settings
set pll [ get_bd_cells pll ]
set_property -dict [list \
    CONFIG.CLKIN1_JITTER_PS {50.0} \
    CONFIG.CLKOUT1_JITTER {112.316} \
    CONFIG.CLKOUT1_PHASE_ERROR {89.971} \
    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {100} \
    CONFIG.CLKOUT2_JITTER {112.316} \
    CONFIG.CLKOUT2_PHASE_ERROR {89.971} \
    CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {100} \
    CONFIG.CLKOUT2_USED {true} \
    CONFIG.MMCM_CLKFBOUT_MULT_F {5.000} \
    CONFIG.MMCM_CLKIN1_PERIOD {5.000} \
    CONFIG.MMCM_CLKIN2_PERIOD {10.0} \
    CONFIG.MMCM_CLKOUT0_DIVIDE_F {10.000} \
    CONFIG.MMCM_CLKOUT1_DIVIDE {10} \
    CONFIG.NUM_OUT_CLKS {2} \
    CONFIG.PRIM_IN_FREQ {200} \
    CONFIG.PRIM_SOURCE {Differential_clock_capable_pin} \
    CONFIG.RESET_PORT {resetn} \
    CONFIG.RESET_TYPE {ACTIVE_LOW} \
    CONFIG.USE_LOCKED {true} \
  ] $pll

# change AXI interconect
set controller_AXI_0_axi_periph [ get_bd_cells controller_AXI_0_axi_periph ]
set_property -dict [list \
	CONFIG.NUM_MI {3} \
	CONFIG.S00_HAS_REGSLICE {1} \
] $controller_AXI_0_axi_periph


# instantiate additional IPs
# Create instance: axi_dmem_ctrl, and set properties
set axi_dmem_ctrl [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_dmem_ctrl ]
set_property CONFIG.SINGLE_PORT_BRAM {1} $axi_dmem_ctrl


# Create instance: axi_imem_ctrl, and set properties
set axi_imem_ctrl [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_imem_ctrl ]
set_property CONFIG.SINGLE_PORT_BRAM {1} $axi_imem_ctrl


# Create instance: imem_gen, and set properties
set imem_gen [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 imem_gen ]

# Create instance: dmem_gen, and set properties
set dmem_gen [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 dmem_gen ]

# Create instance: VexRiscv_Core_0, and set properties
set VexRiscv_Core_0 [ create_bd_cell -type ip -vlnv user.org:user:VexRiscv_Core:1.0 VexRiscv_Core_0 ]

# Create instance: axi_smc_data, and set properties
set axi_smc_data [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 axi_smc_data ]
set_property -dict [list \
CONFIG.NUM_MI {5} \
CONFIG.NUM_SI {2} \
] $axi_smc_data


# Create instance: rst_pll_core, and set properties
set rst_pll_core [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_pll_core ]

# Create instance: axi_smc_inst, and set properties
set axi_smc_inst [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 axi_smc_inst ]
set_property CONFIG.NUM_SI {2} $axi_smc_inst


# Create instance: axi_buffer_0, and set properties
set axi_buffer_0 [ create_bd_cell -type ip -vlnv tkojima.me:user:axi_buffer:1.0 axi_buffer_0 ]

# Create instance: axi_lfsr_0, and set properties
set axi_lfsr_0 [ create_bd_cell -type ip -vlnv tkojima.me:user:axi_lfsr:1.0 axi_lfsr_0 ]

# Create instance: axi_gpio_0, and set properties
set axi_gpio_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0 ]
set_property -dict [list \
	CONFIG.C_ALL_INPUTS_2 {1} \
	CONFIG.C_ALL_OUTPUTS {1} \
	CONFIG.C_GPIO2_WIDTH {8} \
	CONFIG.C_GPIO_WIDTH {10} \
	CONFIG.C_IS_DUAL {1} \
] $axi_gpio_0

# disconnect controller - LED
delete_bd_objs [get_bd_intf_nets controller_AXI_0_axi_periph_M00_AXI]
disconnect_bd_net /pll_clk_out1 [get_bd_pins axi_led/s_axi_aclk]
disconnect_bd_net /rst_pll_100M_peripheral_aresetn [get_bd_pins axi_led/s_axi_aresetn]

# make new interface connection
## core related
connect_bd_intf_net -intf_net VexRiscv_Core_0_M_DATA_AXI [get_bd_intf_pins VexRiscv_Core_0/M_DATA_AXI] [get_bd_intf_pins axi_smc_data/S00_AXI]
connect_bd_intf_net -intf_net VexRiscv_Core_0_M_INST_AXI [get_bd_intf_pins VexRiscv_Core_0/M_INST_AXI] [get_bd_intf_pins axi_smc_inst/S00_AXI]
connect_bd_intf_net -intf_net axi_dmem_ctrl_BRAM_PORTA [get_bd_intf_pins axi_dmem_ctrl/BRAM_PORTA] [get_bd_intf_pins dmem_gen/BRAM_PORTA]
connect_bd_intf_net -intf_net axi_imem_ctrl_BRAM_PORTA [get_bd_intf_pins axi_imem_ctrl/BRAM_PORTA] [get_bd_intf_pins imem_gen/BRAM_PORTA]
connect_bd_intf_net -intf_net axi_smc_1_M00_AXI [get_bd_intf_pins axi_smc_inst/M00_AXI] [get_bd_intf_pins axi_imem_ctrl/S_AXI]
connect_bd_intf_net -intf_net axi_smc_M00_AXI [get_bd_intf_pins axi_smc_data/M00_AXI] [get_bd_intf_pins axi_dmem_ctrl/S_AXI]
connect_bd_intf_net -intf_net axi_smc_M01_AXI [get_bd_intf_pins axi_smc_data/M01_AXI] [get_bd_intf_pins axi_led/S_AXI]
connect_bd_intf_net -intf_net axi_smc_data_M02_AXI [get_bd_intf_pins axi_smc_data/M02_AXI] [get_bd_intf_pins axi_buffer_0/S_AXI]
connect_bd_intf_net -intf_net axi_smc_data_M03_AXI [get_bd_intf_pins axi_smc_data/M03_AXI] [get_bd_intf_pins axi_lfsr_0/S00_AXI]
connect_bd_intf_net -intf_net axi_smc_data_M04_AXI [get_bd_intf_pins axi_smc_data/M04_AXI] [get_bd_intf_pins axi_gpio_0/S_AXI]
## external controller related
connect_bd_intf_net -intf_net controller_AXI_0_M_AXI [get_bd_intf_pins controller_AXI_0/M_AXI] [get_bd_intf_pins controller_AXI_0_axi_periph/S00_AXI]
connect_bd_intf_net -intf_net controller_AXI_0_axi_periph_M00_AXI [get_bd_intf_pins controller_AXI_0_axi_periph/M00_AXI] [get_bd_intf_pins VexRiscv_Core_0/S_CTRL_AXI]
connect_bd_intf_net -intf_net controller_AXI_0_axi_periph_M01_AXI [get_bd_intf_pins controller_AXI_0_axi_periph/M01_AXI] [get_bd_intf_pins axi_smc_inst/S01_AXI]
connect_bd_intf_net -intf_net controller_AXI_0_axi_periph_M02_AXI [get_bd_intf_pins controller_AXI_0_axi_periph/M02_AXI] [get_bd_intf_pins axi_smc_data/S01_AXI]


## Make new port connections
connect_bd_net -net axi_gpio_0_gpio_io_o [get_bd_pins axi_gpio_0/gpio_io_o] [get_bd_ports k_header]

connect_bd_net -net k_dipsw_1 [get_bd_ports k_dipsw] [get_bd_pins axi_gpio_0/gpio2_io_i]

connect_bd_net -net pll_clk_out2 [get_bd_pins pll/clk_out2] [get_bd_pins VexRiscv_Core_0/m_inst_axi_aclk] [get_bd_pins VexRiscv_Core_0/m_data_axi_aclk] [get_bd_pins axi_smc_data/aclk] [get_bd_pins rst_pll_core/slowest_sync_clk] [get_bd_pins axi_dmem_ctrl/s_axi_aclk] [get_bd_pins axi_smc_inst/aclk] [get_bd_pins axi_imem_ctrl/s_axi_aclk] [get_bd_pins axi_led/s_axi_aclk] [get_bd_pins controller_AXI_0_axi_periph/M01_ACLK] [get_bd_pins controller_AXI_0_axi_periph/M02_ACLK] [get_bd_pins axi_buffer_0/s_axi_aclk] [get_bd_pins axi_lfsr_0/s00_axi_aclk] [get_bd_pins axi_gpio_0/s_axi_aclk]

connect_bd_net -net rst_pll_core_peripheral_aresetn [get_bd_pins rst_pll_core/peripheral_aresetn] [get_bd_pins VexRiscv_Core_0/m_data_axi_aresetn] [get_bd_pins axi_dmem_ctrl/s_axi_aresetn] [get_bd_pins axi_smc_data/aresetn] [get_bd_pins VexRiscv_Core_0/m_inst_axi_aresetn] [get_bd_pins axi_imem_ctrl/s_axi_aresetn] [get_bd_pins axi_smc_inst/aresetn] [get_bd_pins axi_led/s_axi_aresetn] [get_bd_pins controller_AXI_0_axi_periph/M01_ARESETN] [get_bd_pins controller_AXI_0_axi_periph/M02_ARESETN] [get_bd_pins axi_buffer_0/s_axi_aresetn] [get_bd_pins axi_lfsr_0/s00_axi_aresetn] [get_bd_pins axi_gpio_0/s_axi_aresetn]

# connecting existing nets
connect_bd_net [get_bd_pins pll/clk_out1] [get_bd_pins VexRiscv_Core_0/s_ctrl_axi_aclk]

connect_bd_net [get_bd_ports i_bus_reset_n] [get_bd_pins rst_pll_core/ext_reset_in]

connect_bd_net [get_bd_pins pll/locked] [get_bd_pins rst_pll_core/dcm_locked]

connect_bd_net [get_bd_pins rst_pll_100M/peripheral_aresetn] [get_bd_pins VexRiscv_Core_0/s_ctrl_axi_aresetn]

# Create address segments
assign_bd_address -offset 0x40000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces controller_AXI_0/M_AXI] [get_bd_addr_segs VexRiscv_Core_0/S_CTRL_AXI/S_CTRL_AXI_reg] -force
assign_bd_address -offset 0xA2000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces controller_AXI_0/M_AXI] [get_bd_addr_segs axi_buffer_0/S_AXI/S_AXI_reg] -force
assign_bd_address -offset 0x81000000 -range 0x00040000 -target_address_space [get_bd_addr_spaces controller_AXI_0/M_AXI] [get_bd_addr_segs axi_dmem_ctrl/S_AXI/Mem0] -force
assign_bd_address -offset 0xA1000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces controller_AXI_0/M_AXI] [get_bd_addr_segs axi_gpio_0/S_AXI/Reg] -force
assign_bd_address -offset 0x80000000 -range 0x00040000 -target_address_space [get_bd_addr_spaces controller_AXI_0/M_AXI] [get_bd_addr_segs axi_imem_ctrl/S_AXI/Mem0] -force
assign_bd_address -offset 0xA0000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces controller_AXI_0/M_AXI] [get_bd_addr_segs axi_led/S_AXI/Reg] -force
assign_bd_address -offset 0xA3000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces controller_AXI_0/M_AXI] [get_bd_addr_segs axi_lfsr_0/S00_AXI/S00_AXI_reg] -force
assign_bd_address -offset 0xA2000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces VexRiscv_Core_0/M_DATA_AXI] [get_bd_addr_segs axi_buffer_0/S_AXI/S_AXI_reg] -force
assign_bd_address -offset 0x81000000 -range 0x00040000 -target_address_space [get_bd_addr_spaces VexRiscv_Core_0/M_DATA_AXI] [get_bd_addr_segs axi_dmem_ctrl/S_AXI/Mem0] -force
assign_bd_address -offset 0xA1000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces VexRiscv_Core_0/M_DATA_AXI] [get_bd_addr_segs axi_gpio_0/S_AXI/Reg] -force
assign_bd_address -offset 0xA0000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces VexRiscv_Core_0/M_DATA_AXI] [get_bd_addr_segs axi_led/S_AXI/Reg] -force
assign_bd_address -offset 0xA3000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces VexRiscv_Core_0/M_DATA_AXI] [get_bd_addr_segs axi_lfsr_0/S00_AXI/S00_AXI_reg] -force
assign_bd_address -offset 0x80000000 -range 0x00040000 -target_address_space [get_bd_addr_spaces VexRiscv_Core_0/M_INST_AXI] [get_bd_addr_segs axi_imem_ctrl/S_AXI/Mem0] -force


# Restore current instance
current_bd_instance $oldCurInst

save_bd_design
