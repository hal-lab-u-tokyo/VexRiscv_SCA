	.file "ex_handler.s"
	.globl _ex_handler
	.text

_ex_handler:
_loop:
	j		_loop ; # loop
	nop
	nop
	nop
	nop
	nop
	nop
	nop

	.end	_ex_handler
