#
#    Copyright (C) 2024 The University of Tokyo
#    
#    File:          /Makefile
#    Project:       sakura-x-vexriscv
#    Author:        Takuya Kojima in The University of Tokyo (tkojima@hal.ipc.i.u-tokyo.ac.jp)
#    Created Date:  07-07-2024 20:39:17
#    Last Modified: 26-02-2025 07:37:49
#

TARGET_BOARD ?= sakura-x

VIVADO_PROJ_NAME ?= $(TARGET_BOARD)-vexriscv

lib/VexRiscv/build.sbt:
	git submodule update --init lib/VexRiscv

vivado/ip_repo/VexRiscv_Core_1_0/src/VexRiscvCore.v: $(wildcard src/main/scala/*.scala) lib/VexRiscv/build.sbt
	@echo "Generating VexRiscvCore.v to vivado/ip_repo/VexRiscv_Core_1_0/src"
	sbt "runMain CoreGen -o vivado/ip_repo/VexRiscv_Core_1_0/src/"

.PHONY: init_vivado_project
ip_repo: vivado/ip_repo/VexRiscv_Core_1_0/src/VexRiscvCore.v

boards/sakura-x-shell:
	git submodule update --init boards/sakura-x-shell

boards/cw305-shell:
	git submodule update --init boards/cw305-shell

ifeq ($(TARGET_BOARD), sakura-x)
init_vivado_project: ip_repo boards/sakura-x-shell
	@echo "Initializing Vivado project"
	vivado -source ./sakura-x-shell/vivado/init-shell-project.tcl \
		-tclargs --project-dir $(VIVADO_PROJ_NAME) --project-name $(VIVADO_PROJ_NAME)
else ifeq ($(TARGET_BOARD), cw305)
init_vivado_project: ip_repo boards/cw305-shell
	@echo "Initializing Vivado project"
	vivado -source ./cw305-shell/vivado/init-shell-project.tcl \
		-tclargs --project-dir $(VIVADO_PROJ_NAME) --project-name $(VIVADO_PROJ_NAME)
else
$(error "TARGET_BOARD must be sakura-x or cw305")
endif

clean:
	rm -rf vivado/ip_repo/VexRiscv_Core_1_0/src/VexRiscvCore.v

