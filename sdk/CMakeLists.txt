

cmake_minimum_required(VERSION 3.14.0)

project(EXPR_RV_CPU_SDK VERSION 0.1)

if(POLICY CMP0068)
  cmake_policy(SET CMP0068 NEW)
  set(CMAKE_BUILD_WITH_INSTRVTOOLCHAINALL_NAME_DIR ON)
endif()

if(POLICY CMP0075)
  cmake_policy(SET CMP0075 NEW)
endif()

if(POLICY CMP0077)
  cmake_policy(SET CMP0077 NEW)
endif()

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)

find_package(RVTOOLCHAIN)


if(NOT DEFINED SDK_DEFAULT_C_COMPILER)
  set(SDK_DEFAULT_C_COMPILER gcc)
  set(CMAKE_C_COMPILER ${RISCV-GCC})
else()
  if (SDK_DEFAULT_C_COMPILER STREQUAL "clang")
    find_package(LLVMTools)
    if (NOT LLVM_TOOLS_FOUND)
      message(FATAL_ERROR "clang is specified for C compiler but not found")
    endif()
    set(CMAKE_C_COMPILER ${LLVM_CLANG})
  elseif (SDK_DEFAULT_C_COMPILER STREQUAL "gcc")
    set(CMAKE_C_COMPILER ${RISCV-GCC})
  else()
    message(FATAL_ERROR "Unknown C compiler: ${SDK_DEFAULT_C_COMPILER}")
  endif()
endif()


include(GNUInstallDirs)

# check SDK_BUILD_TARGET
if(NOT DEFINED SDK_BUILD_TARGET)
  # default target
  set(SDK_BUILD_TARGET "SAKURA-X")
endif()

add_subdirectory(src)
add_subdirectory(template)

install(
  DIRECTORY include/
  TYPE INCLUDE
)

install(
  DIRECTORY ldscripts
  DESTINATION ${CMAKE_INSTALL_PREFIX}/lib
)
