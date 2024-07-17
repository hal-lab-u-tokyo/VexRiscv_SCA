# find gcc executable in PATH
find_program(_rvgcc riscv64-unknown-elf-gcc)

if (NOT _rvgcc)
# find gcc with hints
find_program(_rvgcc riscv64-unknown-elf-gcc
				HINTS "/opt/riscv-gnu-toolchain/bin/")

if (NOT _rvgcc)

message(FATAL_ERROR "RISC-V Toolchain is not found")

endif()

endif()

# test and get versino
execute_process(COMMAND ${_rvgcc} "-dumpfullversion"
				OUTPUT_VARIABLE RISCV-GCC-VERSION
				OUTPUT_STRIP_TRAILING_WHITESPACE)

message("-- Detecting RISC-V GCC version ${RISCV-GCC-VERSION}")

get_filename_component(_bindir ${_rvgcc} DIRECTORY)
get_filename_component(RISCV-TOOLCHAIN-DIR ${_bindir}, DIRECTORY)

set(RISCV-GCC ${_rvgcc})

# cheking library
set(RISCV-GCC-LIB "${RISCV-TOOLCHAIN-DIR}/lib/gcc/riscv64-unknown-elf/${RISCV-GCC-VERSION}/rv32im/ilp32")
if (NOT EXISTS ${RISCV-GCC-LIB})
message(FATAL_ERROR "Cannot find GCC library for RV32")
endif()


