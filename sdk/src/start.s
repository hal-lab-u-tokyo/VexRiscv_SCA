	.extern main
	.globl	_start

_start:
	lui		sp, %hi(_kernelstack)
	addi	sp,sp, %lo(_kernelstack)	# sp (defined @ld.script)

	jal		main
_loop:
	j 	_loop
	nop
	nop
	nop
	nop
	nop

