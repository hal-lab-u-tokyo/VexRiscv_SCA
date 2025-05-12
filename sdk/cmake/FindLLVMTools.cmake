find_program(_clang clang)
find_program(_llc llc)
find_program(_opt opt)

if (_clang AND _llc AND _opt)
	execute_process(COMMAND ${_clang} "-dumpversion"
				OUTPUT_VARIABLE CLANG-VERSION
				OUTPUT_STRIP_TRAILING_WHITESPACE)

	message("-- Detecting CLANG version ${CLANG-VERSION}")
	set(LLVM_TOOLS_FOUND TRUE)
	set(LLVM_CLANG ${_clang})
	set(LLVM_LLC ${_llc})
	set(LLVM_OPT ${_opt})
else()
	message("-- CLANG not found")
	set(LLVM_TOOLS_FOUND FALSE)
endif()