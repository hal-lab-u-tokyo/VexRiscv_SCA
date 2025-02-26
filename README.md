# VexRiscv SCA repository
This repository contains FPGA implementations of the VexRiscv core on the SAKURA-X board and CW305 FPGA board, popular FPGAs for side-channel analysis.
In addition, it includes a software development kit for the VexRiscv core, some fundamental IPs such as pseudo-random number generators and serial communication.
Prebuilt bitstreams configured with default settings are also provided, so you can use the hardware design without building it.

## Prerequisites
- Vivado 2023.2
- Scala 2.11.12
- sbt 1.6.0
- [VexRiscv](https://github.com/SpinalHDL/VexRiscv) (included as a submodule)
- [sakura-x-shell](https://github.com/hal-lab-u-tokyo/sakura-x-shell) (included as a submodule)
- [cw305-shell](https://github.com/hal-lab-u-tokyo/sakura-x-shell) (included as a submodule)


# Configure your boards
## SAKURA-X board
You need to configure both Spartan-6 and Kintex-7 FPGAs on the SAKURA-X board.
Spartan-6 FPGA must be configured with the shell controller design, available in the [sakura-x-shell](https://github.com/hal-lab-u-tokyo/sakura-x-shell/).
Please see the configuration steps in the [documentation](https://github.com/hal-lab-u-tokyo/sakura-x-shell?tab=readme-ov-file#project-for-spartan-6) of the shell repository.

The Kintex-7 FPGA also needs to be configured with the prebuilt bitstream in this repository or your built bitstream.
The following [documentation](https://github.com/hal-lab-u-tokyo/sakura-x-shell/blob/master/doc/config_mcs_vivado.md) will help you configure the Kintex-7 FPGA with Vivado.

## CW305 FPGA board
We also provide a ChipWhisperer extension to use this design.


# Prebuilt Bitstream
Prebuilt bitstream files are available in the [bitstream](./bitstream/) directory.

## Resource Usage
The following implementation results are obtained with Vivado 2023.2, specifying the [default configuration](./src/main/scala/CpuConfig.scala) and 100MHz clock frequency for the VexRiscv core.
The block design uses 256KB block memory for instruction and data memory, respectively.

|| Slice LUTs | Slice Registers | BRAMs | DSPs |
|:-:|:-:|:-:|:-:|:-:|
Total | 14911 (14.71%) | 16491 (8.13%) | 138 (42.46%) | 7 (1.17%)  |
VexRiscv Core | 3962 (3.91%) | 3408 (1.68%)| 8 (2.46%) | 7 (1.17%) |

# Included IPs
## [VexRiscv_Core](./vivado/ip_repo/VexRiscv_Core_1_0/)
This is a wrapper IP for the VexRiscv core, including the AXI4-Lite interface for core control.

### Address Map of control registers
| Address | Description | Note |
|:-:|:-:|:-:|
| `BASE` + 0x00 | start enable | Write 1 to start the core |
| `BASE` + 0x04 | external interrupt enable | LSB is connected external interrupt signal of the core (not tested yet) |

## [AXI LFSR](./vivado/ip_repo/axi_lfsr_1_0/)
This provides a memory-mapped linear feedback shift register (LFSR) for pseudo-random number generation.
| Address | Description | Note |
|:-:|:-:|:-:|
| `BASE` + 0x00 | Seed | 32-bit seed for the LFSR (use non-zero value) |
| `BASE` + 0x04 | LFSR output | 32-bit pseudo-random number |


## [AXI Buffer](./vivado/ip_repo/axi_buffer_1_0/)
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
The default project name is `<board_name>-vexriscv`. If you want to change the project name, execute the following command.
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

# Simple Test
After configuring the FPGA with the bitstream, you can test the VexRiscv core by running the following command.

Note that that python script needs [chipwhisperer](https://github.com/newaetech/chipwhisperer) and our [chipwhisperer-enhanced-plugins](https://github.com/hal-lab-u-tokyo/chipwhisperer-enhanced-plugins/) to be installed.

```bash
python3 test/test_hello_world.py <serial port path> [--baudrate <baudrate>] [--timeout <timeout>]
```

`<serial port path>` is the path to the serial port connected to the Kintex-7 FPGA.
`--baudrate` and `--timeout` are optional arguments to specify the baudrate and end time of the test, respectively.

Expected output:
```
[INFO] Loaded 3 segments
[INFO] boot start
[INFO] boot end
[INFO] Core start
Hello, World! 0
Hello, World! 1
Hello, World! 2
Hello, World! 3
Hello, World! 4
Hello, World! 5
Hello, World! 6
Hello, World! 7
Hello, World! 8
Hello, World! 9
```

# Application Development
## Build and Install software development kit
This repository includes a software development kit for VexRiscv on the SAKURA-X board with a simply implemented library.

The following commands will build and install the SDK.
The installation path can be specified with the `CMAKE_INSTALL_PREFIX` option.
```
mkdir build
cmake [-DCMAKE_INSTALL_PREFIX=<install path>] <path to this repository>/sdk
cmake --build .
cmake --install .
```

## Create a new application
Please create a c source file app_name.c and Makefile as follows.

```Makefile
.PHONY: all, clean
all: app_name.elf

clean:
	-rm -f *.{o,elf,disasm}
include  ${SDK_DIR}/etc/Makefile.common
```

`app_name` can be any name you like.

### Compile options
In the Makefile, you can specify the optimization level by adding the following line in the Makefile.
```Makefile
OPT_FLAGS = -O2
```

Likewise, you can specify the compiler flags by adding the following line in the Makefile.
```Makefile
EXTRA_CFLAGS = --foo --bar
```

If you have multiple source files, for example, `a.c` and `b.c`, you can add the following line in the Makefile.
```Makefile
EXTRA_OBJ = a.o b.o
```

# License
This repository is licensed under the MIT license. See [LICENSE](./LICENSE) for details.
