lib/VexRiscv:
	git submodule update lib/VexRiscv

hoge: lib/VexRiscv
	@echo "hoge"
	sbt "runMain sakura_x_vexriscv.SakuraXVexRiscVCoreGen"