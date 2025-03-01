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
import_files -fileset $constr_set [file normalize [file join $scriptDir "gpio_cw305.xdc"]]

# ROM COE file path
set rom_file_path [file normalize [file join $scriptDir ".." "bootloader" "boot.coe"]]
if { [file exists $rom_file_path] == 0 } {
  set errMsg "ROM COE file not found at <$rom_file_path>."
  common::send_gid_msg -ssname BD::TCL -id 2005 -severity "ERROR" $errMsg
  return -code error $errMsg
}

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
set HEADER_OUT [ create_bd_port -dir O -from 11 -to 0 HEADER_OUT ]
set DIP [ create_bd_port -dir I -from 3 -to 0 DIP ]

# change PLL settings
set pll [ get_bd_cells pll ]
set_property -dict [list \
  CONFIG.CLKOUT1_JITTER {183.243} \
  CONFIG.CLKOUT1_PHASE_ERROR {98.575} \
  CONFIG.CLKOUT2_JITTER {130.958} \
  CONFIG.CLKOUT2_PHASE_ERROR {98.575} \
  CONFIG.CLKOUT2_USED {true} \
  CONFIG.MMCM_CLKFBOUT_MULT_F {10.000} \
  CONFIG.MMCM_CLKOUT0_DIVIDE_F {50.000} \
  CONFIG.MMCM_CLKOUT1_DIVIDE {10} \
  CONFIG.NUM_OUT_CLKS {2} \
] [get_bd_cells pll]

# Create instance: rst_sys_clk, and set properties
set rst_core_clk [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_core_clk ]

# change AXI interconect
set usb_interface_0_axi_periph [ get_bd_cells usb_interface_0_axi_periph ]
set_property -dict [list \
	CONFIG.NUM_MI {3} \
] $usb_interface_0_axi_periph

# instantiate additional IPs
# Create instance: axi_dmem_ctrl, and set properties
set axi_dmem_ctrl [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_dmem_ctrl ]
set_property CONFIG.SINGLE_PORT_BRAM {1} $axi_dmem_ctrl

# Create instance: axi_imem_ctrl, and set properties
set axi_imem_ctrl [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_imem_ctrl ]
set_property CONFIG.SINGLE_PORT_BRAM {1} $axi_imem_ctrl

# Create instance: axi_rom_ctrl, and set properties
set axi_rom_ctrl [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_rom_ctrl ]
set_property CONFIG.SINGLE_PORT_BRAM {1} $axi_rom_ctrl

# Create instance: imem_gen, and set properties
set imem_gen [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 imem_gen ]

# Create instance: dmem_gen, and set properties
set dmem_gen [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 dmem_gen ]

# Create instance: rom_gen, and set properties
set rom_gen [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 rom_gen ]
set_property -dict [list \
  CONFIG.Coe_File $rom_file_path \
  CONFIG.Load_Init_File {true} \
  CONFIG.Memory_Type {Single_Port_ROM} \
] $rom_gen

# Create instance: VexRiscv_Core_0, and set properties
set VexRiscv_Core_0 [ create_bd_cell -type ip -vlnv user.org:user:VexRiscv_Core:1.0 VexRiscv_Core_0 ]

# Create instance: axi_smc_data, and set properties
set axi_smc_data [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 axi_smc_data ]
set_property -dict [list \
  CONFIG.NUM_MI {5} \
  CONFIG.NUM_SI {2} \
] $axi_smc_data

# Create instance: axi_smc_inst, and set properties
set axi_smc_inst [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 axi_smc_inst ]
set_property -dict [list \
  CONFIG.NUM_MI {2} \
  CONFIG.NUM_SI {2} \
] $axi_smc_inst

# Create instance: axi_buffer_0, and set properties
set axi_buffer_0 [ create_bd_cell -type ip -vlnv tkojima.me:user:axi_buffer:1.0 axi_buffer_0 ]

# Create instance: axi_lfsr_0, and set properties
set axi_lfsr_0 [ create_bd_cell -type ip -vlnv tkojima.me:user:axi_lfsr:1.0 axi_lfsr_0 ]

# Create instance: axi_gpio_0, and set properties
set axi_gpio_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0 ]
set_property -dict [list \
  CONFIG.C_ALL_INPUTS_2 {1} \
  CONFIG.C_ALL_OUTPUTS {1} \
  CONFIG.C_GPIO2_WIDTH {4} \
  CONFIG.C_GPIO_WIDTH {12} \
  CONFIG.C_IS_DUAL {1} \
] $axi_gpio_0

# disconnect usb interface - GPIO
delete_bd_objs [get_bd_intf_nets usb_interface_0_axi_periph_M00_AXI]
disconnect_bd_net /sys_clk_1 [get_bd_pins axi_led/s_axi_aclk]
disconnect_bd_net /rst_sys_clk_peripheral_aresetn [get_bd_pins axi_led/s_axi_aresetn]

# make new interface connection
## core related
connect_bd_intf_net -intf_net VexRiscv_Core_0_M_DATA_AXI [get_bd_intf_pins VexRiscv_Core_0/M_DATA_AXI] [get_bd_intf_pins axi_smc_data/S00_AXI]
connect_bd_intf_net -intf_net VexRiscv_Core_0_M_INST_AXI [get_bd_intf_pins VexRiscv_Core_0/M_INST_AXI] [get_bd_intf_pins axi_smc_inst/S00_AXI]
connect_bd_intf_net -intf_net axi_dmem_ctrl_BRAM_PORTA [get_bd_intf_pins axi_dmem_ctrl/BRAM_PORTA] [get_bd_intf_pins dmem_gen/BRAM_PORTA]
connect_bd_intf_net -intf_net axi_imem_ctrl_BRAM_PORTA [get_bd_intf_pins axi_imem_ctrl/BRAM_PORTA] [get_bd_intf_pins imem_gen/BRAM_PORTA]
connect_bd_intf_net -intf_net axi_rom_ctrl_BRAM_PORTA [get_bd_intf_pins axi_rom_ctrl/BRAM_PORTA] [get_bd_intf_pins rom_gen/BRAM_PORTA]
connect_bd_intf_net -intf_net axi_smc_inst_M00_AXI [get_bd_intf_pins axi_smc_inst/M00_AXI] [get_bd_intf_pins axi_imem_ctrl/S_AXI]
connect_bd_intf_net -intf_net axi_smc_inst_M01_AXI [get_bd_intf_pins axi_smc_inst/M01_AXI] [get_bd_intf_pins axi_rom_ctrl/S_AXI]

connect_bd_intf_net -intf_net axi_smc_data_M00_AXI [get_bd_intf_pins axi_smc_data/M00_AXI] [get_bd_intf_pins axi_dmem_ctrl/S_AXI]
connect_bd_intf_net -intf_net axi_smc_data_M01_AXI [get_bd_intf_pins axi_smc_data/M01_AXI] [get_bd_intf_pins axi_led/S_AXI]
connect_bd_intf_net -intf_net axi_smc_data_M02_AXI [get_bd_intf_pins axi_smc_data/M02_AXI] [get_bd_intf_pins axi_buffer_0/S_AXI]
connect_bd_intf_net -intf_net axi_smc_data_M03_AXI [get_bd_intf_pins axi_smc_data/M03_AXI] [get_bd_intf_pins axi_lfsr_0/S00_AXI]
connect_bd_intf_net -intf_net axi_smc_data_M04_AXI [get_bd_intf_pins axi_smc_data/M04_AXI] [get_bd_intf_pins axi_gpio_0/S_AXI]


## to/from USB Interface
connect_bd_intf_net -intf_net usb_interface_0_axi_periph_M00_AXI [get_bd_intf_pins usb_interface_0_axi_periph/M00_AXI] [get_bd_intf_pins VexRiscv_Core_0/S_CTRL_AXI]
connect_bd_intf_net -intf_net usb_interface_0_axi_periph_M01_AXI [get_bd_intf_pins usb_interface_0_axi_periph/M01_AXI] [get_bd_intf_pins axi_smc_inst/S01_AXI]
connect_bd_intf_net -intf_net usb_interface_0_axi_periph_M02_AXI [get_bd_intf_pins usb_interface_0_axi_periph/M02_AXI] [get_bd_intf_pins axi_smc_data/S01_AXI]

## Make new port connections
connect_bd_net -net axi_gpio_0_gpio_io_o [get_bd_pins axi_gpio_0/gpio_io_o] [get_bd_ports HEADER_OUT]
connect_bd_net -net k_dipsw_1 [get_bd_ports DIP] [get_bd_pins axi_gpio_0/gpio2_io_i]

# connecting existing nets
## clock signals
connect_bd_net -net core_clk [get_bd_pins pll/clk_out2] [get_bd_pins VexRiscv_Core_0/m_inst_axi_aclk] [get_bd_pins VexRiscv_Core_0/m_data_axi_aclk] [get_bd_pins axi_smc_data/aclk] [get_bd_pins axi_dmem_ctrl/s_axi_aclk] [get_bd_pins axi_smc_inst/aclk] [get_bd_pins axi_imem_ctrl/s_axi_aclk] [get_bd_pins axi_rom_ctrl/s_axi_aclk] [get_bd_pins axi_buffer_0/s_axi_aclk] [get_bd_pins axi_lfsr_0/s00_axi_aclk] [get_bd_pins axi_gpio_0/s_axi_aclk] [get_bd_pins axi_led/s_axi_aclk] [get_bd_pins usb_interface_0_axi_periph/M01_ACLK] [get_bd_pins usb_interface_0_axi_periph/M02_ACLK] [get_bd_pins rst_core_clk/slowest_sync_clk]

connect_bd_net [get_bd_pins pll/clk_out1] [get_bd_pins VexRiscv_Core_0/s_ctrl_axi_aclk]

## reset signals
connect_bd_net [get_bd_pins rst_core_clk/peripheral_aresetn] [get_bd_pins VexRiscv_Core_0/m_data_axi_aresetn] [get_bd_pins axi_dmem_ctrl/s_axi_aresetn] [get_bd_pins axi_smc_data/aresetn] [get_bd_pins VexRiscv_Core_0/m_inst_axi_aresetn] [get_bd_pins axi_imem_ctrl/s_axi_aresetn] [get_bd_pins axi_rom_ctrl/s_axi_aresetn] [get_bd_pins axi_smc_inst/aresetn] [get_bd_pins axi_buffer_0/s_axi_aresetn] [get_bd_pins axi_lfsr_0/s00_axi_aresetn] [get_bd_pins axi_gpio_0/s_axi_aresetn] [get_bd_pins axi_led/s_axi_aresetn]  [get_bd_pins usb_interface_0_axi_periph/M01_ARESETN] [get_bd_pins usb_interface_0_axi_periph/M02_ARESETN]

connect_bd_net [get_bd_pins rst_sys_clk/peripheral_aresetn] [get_bd_pins VexRiscv_Core_0/s_ctrl_axi_aresetn]

connect_bd_net [get_bd_ports RESET_N] [get_bd_pins rst_core_clk/ext_reset_in]
connect_bd_net [get_bd_pins usb_interface_0/sw_reset_n] [get_bd_pins rst_core_clk/aux_reset_in]
connect_bd_net [get_bd_pins pll/locked] [get_bd_pins rst_core_clk/dcm_locked]

# Create address segments
assign_bd_address -offset 0x40000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces usb_interface_0/M00_AXI] [get_bd_addr_segs VexRiscv_Core_0/S_CTRL_AXI/S_CTRL_AXI_reg] -force
assign_bd_address -offset 0xA2000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces usb_interface_0/M00_AXI] [get_bd_addr_segs axi_buffer_0/S_AXI/S_AXI_reg] -force
assign_bd_address -offset 0x82000000 -range 0x00040000 -target_address_space [get_bd_addr_spaces usb_interface_0/M00_AXI] [get_bd_addr_segs axi_dmem_ctrl/S_AXI/Mem0] -force
assign_bd_address -offset 0xA0000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces controller_AXI_0/M_AXI] [get_bd_addr_segs axi_led/S_AXI/Reg] -force
assign_bd_address -offset 0xA1000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces usb_interface_0/M00_AXI] [get_bd_addr_segs axi_gpio_0/S_AXI/Reg] -force
assign_bd_address -offset 0x81000000 -range 0x00020000 -target_address_space [get_bd_addr_spaces usb_interface_0/M00_AXI] [get_bd_addr_segs axi_imem_ctrl/S_AXI/Mem0] -force
assign_bd_address -offset 0xA3000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces usb_interface_0/M00_AXI] [get_bd_addr_segs axi_lfsr_0/S00_AXI/S00_AXI_reg] -force

assign_bd_address -offset 0xA2000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces VexRiscv_Core_0/M_DATA_AXI] [get_bd_addr_segs axi_buffer_0/S_AXI/S_AXI_reg] -force
assign_bd_address -offset 0x82000000 -range 0x00040000 -target_address_space [get_bd_addr_spaces VexRiscv_Core_0/M_DATA_AXI] [get_bd_addr_segs axi_dmem_ctrl/S_AXI/Mem0] -force
assign_bd_address -offset 0xA0000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces VexRiscv_Core_0/M_DATA_AXI] [get_bd_addr_segs axi_led/S_AXI/Reg] -force
assign_bd_address -offset 0xA1000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces VexRiscv_Core_0/M_DATA_AXI] [get_bd_addr_segs axi_gpio_0/S_AXI/Reg] -force
assign_bd_address -offset 0xA3000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces VexRiscv_Core_0/M_DATA_AXI] [get_bd_addr_segs axi_lfsr_0/S00_AXI/S00_AXI_reg] -force
assign_bd_address -offset 0x80000000 -range 0x00002000 -target_address_space [get_bd_addr_spaces VexRiscv_Core_0/M_INST_AXI] [get_bd_addr_segs axi_rom_ctrl/S_AXI/Mem0] -force
assign_bd_address -offset 0x81000000 -range 0x00020000 -target_address_space [get_bd_addr_spaces VexRiscv_Core_0/M_INST_AXI] [get_bd_addr_segs axi_imem_ctrl/S_AXI/Mem0] -force

# Restore current instance
current_bd_instance $oldCurInst

save_bd_design