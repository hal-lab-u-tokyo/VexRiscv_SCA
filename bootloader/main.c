void main(void)
{
	extern unsigned int _imem;
	__asm__ ("jalr %0" : : "r" (&_imem));
}