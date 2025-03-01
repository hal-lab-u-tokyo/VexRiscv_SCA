set_property -dict {PACKAGE_PIN J16  IOSTANDARD LVCMOS33} [get_ports DIP[0]];			# IO_L23N_T3_FWE_B_15
set_property -dict {PACKAGE_PIN K16  IOSTANDARD LVCMOS33} [get_ports DIP[1]];			# IO_L2N_T0_D03_14
set_property -dict {PACKAGE_PIN K15  IOSTANDARD LVCMOS33} [get_ports DIP[2]];			# IO_L2P_T0_D02_14
set_property -dict {PACKAGE_PIN L14  IOSTANDARD LVCMOS33} [get_ports DIP[3]];			# IO_L4P_T0_D04_14

set_property -dict {PACKAGE_PIN A12 IOSTANDARD LVCMOS33} [get_ports HEADER_OUT[0] ];		# IO_L5N_T0_AD9N_15
set_property -dict {PACKAGE_PIN A14 IOSTANDARD LVCMOS33} [get_ports HEADER_OUT[1] ];		# IO_L7N_T1_AD2N_15
set_property -dict {PACKAGE_PIN A15 IOSTANDARD LVCMOS33} [get_ports HEADER_OUT[2] ];		# IO_L9N_T1_DQS_AD3N_15
set_property -dict {PACKAGE_PIN C12 IOSTANDARD LVCMOS33} [get_ports HEADER_OUT[3] ];		# IO_L11N_T1_SRCC_15
set_property -dict {PACKAGE_PIN B14 IOSTANDARD LVCMOS33} [get_ports HEADER_OUT[4] ];		# IO_L8N_T1_AD10N_15
set_property -dict {PACKAGE_PIN B16 IOSTANDARD LVCMOS33} [get_ports HEADER_OUT[5] ];		# IO_L10N_T1_AD11N_15
set_property -dict {PACKAGE_PIN C13 IOSTANDARD LVCMOS33} [get_ports HEADER_OUT[6] ];		# IO_L12N_T1_MRCC_15
set_property -dict {PACKAGE_PIN D15 IOSTANDARD LVCMOS33} [get_ports HEADER_OUT[7] ];		# IO_L15N_T2_DQS_ADV_B_15
set_property -dict {PACKAGE_PIN E15 IOSTANDARD LVCMOS33} [get_ports HEADER_OUT[8] ];		# IO_L18N_T2_A23_15
set_property -dict {PACKAGE_PIN E13 IOSTANDARD LVCMOS33} [get_ports HEADER_OUT[9] ];		# IO_L13N_T2_MRCC_15
set_property -dict {PACKAGE_PIN F15 IOSTANDARD LVCMOS33} [get_ports HEADER_OUT[10] ];	# IO_L18P_T2_A24_15
set_property -dict {PACKAGE_PIN E11 IOSTANDARD LVCMOS33} [get_ports HEADER_OUT[11] ];	# IO_L14P_T2_SRCC_15


set_input_delay -add_delay 0.0 [get_ports DIP]
set_false_path -from [get_ports DIP]

set_output_delay -add_delay 0.0 [get_ports HEADER_OUT]
set_false_path -to [get_ports HEADER_OUT]