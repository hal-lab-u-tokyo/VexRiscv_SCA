#
#    Copyright (C) 2024 The University of Tokyo
#    
#    File:          /Makefile
#    Project:       sakura-x-vexriscv
#    Author:        Takuya Kojima in The University of Tokyo (tkojima@hal.ipc.i.u-tokyo.ac.jp)
#    Created Date:  07-07-2024 20:39:17
#    Last Modified: 14-07-2024 23:52:11
#

VIVADO_PROJ_NAME ?= sakura-x-vexriscv

lib/VexRiscv/build.sbt:
	git submodule update --init lib/VexRiscv

vivado/ip_repo/VexRiscv_Core_1_0/src/VexRiscvCore.v: $(wildcard src/main/scala/*.scala) lib/VexRiscv/build.sbt
	@echo "Generating VexRiscvCore.v to vivado/ip_repo/VexRiscv_Core_1_0/src"
	sbt "runMain CoreGen -o vivado/ip_repo/VexRiscv_Core_1_0/src/"

.PHONY: init_vivado_project
ip_repo: vivado/ip_repo/VexRiscv_Core_1_0/src/VexRiscvCore.v

sakura-x-shell:
	git submodule update --init sakura-x-shell

init_vivado_project: ip_repo sakura-x-shell
	@echo "Initializing Vivado project"
	vivado -source ./sakura-x-shell/vivado/init-shell-project.tcl \
		-tclargs --project-dir $(VIVADO_PROJ_NAME) --project-name $(VIVADO_PROJ_NAME)

clean:
	rm -rf vivado/ip_repo/VexRiscv_Core_1_0/src/VexRiscvCore.v

