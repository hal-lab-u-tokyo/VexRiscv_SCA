# VexRiscv SAKURA-X
This repository helps your side-channel analysis research on the SAKURA-X board.
It contains an FPGA design implementing the VexRiscv core on the SAKURA-X board, a software design kit for the core, and some IPs for the board.
In addition, prebuilt bitstreams are included, so you can use the hardware design without building it.

## Prerequisites
- Vivado 2023.2
- Scala 2.11.12
- sbt 1.6.0
- [VexRiscv](https://github.com/SpinalHDL/VexRiscv) (automatically cloned by building tool)
- [sakura-x-shell](https://github.com/hal-lab-u-tokyo/sakura-x-shell) (included as a submodule)

# Configure your board
You need to configure both Spartan-6 and Kintex-7 FPGAs on the SAKURA-X board.
Spartan-6 FPGA must be configured with the shell controller design, available in the [sakura-x-shell](https://github.com/hal-lab-u-tokyo/sakura-x-shell/).
Please see the configuration steps in the [documentation](https://github.com/hal-lab-u-tokyo/sakura-x-shell?tab=readme-ov-file#project-for-spartan-6) of the shell repository.

The Kintex-7 FPGA also needs to be configured with the prebuilt bitstream in this repository or your built bitstream.
The following [documentation](https://github.com/hal-lab-u-tokyo/sakura-x-shell/blob/master/doc/config_mcs_vivado.md) will help you configure the Kintex-7 FPGA with Vivado.

# Prebuilt Bitstream
Prebuilt bitstream files are available in the [bitstream](./bitstream/) directory.

## Resource Usage
The following implementation results are obtained with Vivado 2023.2, specifying the [default configuration](./src/main/scala/CpuConfig.scala) and 100MHz clock frequency for the VexRiscv core.
The block design uses 256KB block memory for instruction and data memory, respectively.

|| Slice LUTs | Slice Registers | BRAMs | DSPs |
|:-:|:-:|:-:|:-:|:-:|
Total | 13788 (13.60%) | 15294 (7.54%) | 136 (41.85%) | 7 (1.17%)  |
VexRiscv Core | 3828 (3.78%) | 3403 (1.68%)| 8 (2.46%) | 7 (1.18%) |

# Included IPs
## [VexRiscv_Core](./ip_repo/VexRiscv_Core_1_0/)
This is a wrapper IP for the VexRiscv core, including the AXI4-Lite interface for core control.

### Address Map of control registers
| Address | Description | Note |
|:-:|:-:|:-:|
| `BASE` + 0x00 | start enable | Write 1 to start the core |
| `BASE` + 0x04 | external interrupt enable | LSB is connected external interrupt signal of the core (not tested yet) |

## [AXI LFSR](./ip_repo/axi_lfsr_1_0/)
This provides a memory-mapped linear feedback shift register (LFSR) for pseudo-random number generation.
| Address | Description | Note |
|:-:|:-:|:-:|
| `BASE` + 0x00 | Seed | 32-bit seed for the LFSR (use non-zero value) |
| `BASE` + 0x04 | LFSR output | 32-bit pseudo-random number |


## [AXI Buffer](./ip_repo/axi_buffer_1_0/)
This is used for serial-like communication with Spartan-6 FPGA on the SAKURA-X board.

| Address | Description | Note |
|:-:|:-:|:-:|
| `BASE` + 0x00 | tx_data | 8-bit data to be transmitted |
| `BASE` + 0x04 | tx_status | See below |
| `BASE` + 0x08 | rx_data | 8-bit received data |
| `BASE` + 0x0C | rx_status | See below |

Both `tx_status` and `rx_status` are 32-bit registers as formatted below:

| 31:16 | 15:9 | 8 | 7:1 | 0 |
|:-:|:-:|:-:|:-:|:-:|
| Number of bytes in buffer | Don't care | Full | Don't care | Empty |

The `Full` and `Empty` bits are set when the buffer is full or empty, respectively.

# Building the Design
## 1. Core generation
First, you need to generate the VexRiscv core.
Execute the following command in the root directory of this repository.
```bash
make ip_core
```
It will automatically clone the VexRiscv repository and generate the core according to the configuration in [CpuConfig.scala](./src/main/scala/CpuConfig.scala).

## 2. Create a Vivado project
Execute the following command to create a Vivado project.
```bash
make init_vivado_project
```
The default project name is `sakura-x-vexriscv`. If you want to change the project name, execute the following command.
```bash
make VIVADO_PROJ_NAME=<your_project_name> init_vivado_project
```

After executing the command, vivado will be launched with a template block design.

## 3. Create block design
In the Vivado Tcl console, execute the following command to create a block design.
```tcl
source <path to this repo>/vivado/create_bd.tcl
```

## 4. Generate bitstream
After creating the block design, generate the bitstream by clicking the `Generate Bitstream` button in the Vivado GUI.



