	.extern main
	.globl	_zsbl_start

_zsbl_start:
	la		t0, _trap_handler
	csrw	mtvec, t0 # set base to _trap_handler, mode direct
	lui		sp, %hi(_kernelstack)
	addi	sp,sp, %lo(_kernelstack)	# sp (defined @ld.script)

	jal		main
	nop
	nop
	nop
	nop
