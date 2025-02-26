.section .trap

_trap:
	# get exception cause
	csrr	t0, mcause
	# MMIO LED address
	li		a0, 0xA0000000
	# set the LED to the exception cause
	sw 		t0, 0(a0)

_loop:
	j		_loop ; # loop
	nop
	nop
	nop
	nop
	nop
