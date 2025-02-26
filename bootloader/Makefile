#
#    Copyright (C) 2023 The University of Tokyo
#    
#    File:          /bootloader/Makefile
#    Project:       expr-riscv
#    Author:        Takuya Kojima in The University of Tokyo (tkojima@hal.ipc.i.u-tokyo.ac.jp)
#    Created Date:  07-12-2023 09:28:07
#    Last Modified: 27-02-2025 03:32:06
#

OPT_LEVEL = -Os
include  ${SDK_DIR}/etc/Makefile.common
LDSCRIPT = ./ld.script
LDFLAGS := -T$(LDSCRIPT) -L$(GCC_LIB)

define compile
	$(CC) $(CFLAGS) $(EXTRA_CFLAGS) -c $(1) -o $(2)
	$(STRIP) --strip-debug $(2)
endef

.SUFFIXES:
.SUFFIXES: .c .o .s

all: boot.coe

%.o: %.c
	$(call compile,$^,$@)

boot.o: boot.s
	$(call compile,$^,$@)

trap.o: trap.s
	$(call compile,$^,$@)

boot.elf: boot.o main.o trap.o
	$(LD) $(LDFLAGS) main.o -o $@ -lgcc
	$(STRIP) --strip-debug $@

%.bin: %.elf
	$(OBJCOPY) -O binary --only-section=.text --only-section=.trap $^ $*.bin

%.hex: %.bin
	xxd -e -g 4 -c 4 $*.bin | awk '{print $$2}'  > $*.hex

%.coe: %.hex
	printf "memory_initialization_radix=16;\nmemory_initialization_vector=\n" > $@
	cat $< | awk 'NR==1 {first=1} {if (!first) printf ",\n"; printf "%s", $$0; first=0} END {printf ";\n"}'  >> $@



.PHONY: clean
clean:
	rm -f *.o *.elf *.bin *.hex