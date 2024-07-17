set(CMAKE_C_COMPILER ${RISCV-GCC})

# FLAG of bulding library for RTL simulation
set (BUILD_SIMULATION_LIB OFF CACHE BOOL "Build a static library for RTL simulation")

# source file list of RISC-V library
set(MINILIB_SRCS
	gpio.c
	iolib.c
	led.c
	printf.c
	rand.c
	scanf.c
	serial.c
	string.c
)

# merge both source lists
set(LIB_SRCS "")

foreach (SRC IN LISTS MINILIB_SRCS)
	list(APPEND LIB_SRCS "./${SRC}")
endforeach()


# create libminilib.a
add_library(minilib STATIC ${LIB_SRCS})
target_include_directories(minilib PRIVATE
							${CMAKE_CURRENT_SOURCE_DIR}/include
							${CMAKE_SOURCE_DIR}/include
							)

# compiler flags
set ( GCC_OPTS
	"-march=rv32im"
	"-mabi=ilp32"
	"-static"
	"-fno-builtin"
	"-g0"
	"-O2"
)

target_compile_options(minilib PRIVATE ${GCC_OPTS})

enable_language(ASM)
# start up routine
add_library(start OBJECT start.s)
target_compile_options(start PRIVATE ${GCC_OPTS})
# exception handler
add_library(ex_handler OBJECT ex_handler.s)
target_compile_options(ex_handler PRIVATE ${GCC_OPTS})

install(FILES $<TARGET_OBJECTS:start>
		DESTINATION lib
		RENAME start.o
)

install(FILES $<TARGET_OBJECTS:ex_handler>
		DESTINATION lib
		RENAME ex_handler.o
)

install(TARGETS minilib
		DESTINATION lib
)

