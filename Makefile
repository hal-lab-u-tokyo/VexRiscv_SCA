VexRiscv:
	git submodule update VexRiscv

ip_repo/VexRiscv_1_0/src/VexRiscvCore.v: VexRiscv
	@echo "Generating VexRiscvCore.v to ip_repo/VexRiscv_1_0/src/"
	sbt "runMain CoreGen -o ip_repo/VexRiscv_1_0/src/"

.PHONY: ip_repo
ip_repo: ip_repo/VexRiscv_1_0/src/VexRiscvCore.v

