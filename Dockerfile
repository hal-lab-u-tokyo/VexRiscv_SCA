FROM ubuntu:24.04

LABEL "maintainer"="Takuya Kojima (tkojima@hal.ipc.i.u-tokyo.ac.jp)"

ARG DEBIAN_FRONTEND=noninteractive
ARG PREREQUISITES="autoconf automake autotools-dev curl python3 python3-pip libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev ninja-build git cmake libglib2.0-dev libslirp-dev libelf-dev libffi-dev bzip2"

ARG RELEASE_VERSION="2025.05.10"
ARG LLVM_VERSION="llvmorg-19.1.7"

WORKDIR /tmp

# Build RISCV toolchain and LLVM & erase temp files
RUN apt update && \
	apt install -y $PREREQUISITES && \
	git clone https://github.com/riscv/riscv-gnu-toolchain -b ${RELEASE_VERSION} && \
	cd riscv-gnu-toolchain && \
	./configure --prefix=/opt/riscv --enable-multilib && \
	make -j$(nproc) && make install && \
	cd /tmp && \
	rm -rf /tmp/riscv-gnu-toolchain && \
	git clone -b ${LLVM_VERSION} https://github.com/llvm/llvm-project.git && \
	mkdir /tmp/llvm-project/build && \
	cd /tmp/llvm-project/build && \
	cmake -G "Ninja"  -DCMAKE_BUILD_TYPE="Release" \
		-DLLVM_ENABLE_PROJECTS="clang;" \
		-DCMAKE_INSTALL_PREFIX=/opt/llvm \
		-DLLVM_ENABLE_ASSERTIONS=On \
		../llvm && \
	cmake --build .  && \
	cmake --install . && \
	cd /tmp && \
	rm -rf /tmp/llvm-project && \
	apt clean && \
	rm -rf /var/lib/apt/lists/*

ENV PATH="/opt/riscv/bin:/opt/llvm/bin:${PATH}"

RUN { \
		echo "/opt/llvm/lib"; \
} >> /etc/ld.so.conf.d/20-llvm.conf

RUN ldconfig

# build SDK
COPY ./sdk /usr/src/vexriscv-sca-sdk
# SAKURA-X gcc version
RUN mkdir -p /tmp/build && \
	cd /tmp/build && \
	cmake -DCMAKE_INSTALL_PREFIX=/opt/vexriscv-sca-sdk/sakura-x-gcc \
		-DCMAKE_BUILD_TYPE=Release \
		-DSDK_BUILD_TARGET=SAKURA-X \
		-DSDK_DEFAULT_C_COMPILER=gcc \
		/usr/src/vexriscv-sca-sdk && \
	cmake --build . -j$(nproc) && \
	cmake --install . && \
	rm -rf /tmp/build

# SAKURA-X clang version
RUN mkdir -p /tmp/build && \
	cd /tmp/build && \
	cmake -DCMAKE_INSTALL_PREFIX=/opt/vexriscv-sca-sdk/sakura-x-clang \
		-DCMAKE_BUILD_TYPE=Release \
		-DSDK_BUILD_TARGET=SAKURA-X \
		-DSDK_DEFAULT_C_COMPILER=clang \
		/usr/src/vexriscv-sca-sdk && \
	cmake --build . -j$(nproc) && \
	cmake --install . && \
	rm -rf /tmp/build

# CW305 GCC version
RUN mkdir -p /tmp/build && \
	cd /tmp/build && \
	cmake -DCMAKE_INSTALL_PREFIX=/opt/vexriscv-sca-sdk/cw305-gcc \
		-DCMAKE_BUILD_TYPE=Release \
		-DSDK_BUILD_TARGET=CW305 \
		-DSDK_DEFAULT_C_COMPILER=gcc \
		/usr/src/vexriscv-sca-sdk && \
	cmake --build . -j$(nproc) && \
	cmake --install . && \
	rm -rf /tmp/build

# CW305 clang version
RUN mkdir -p /tmp/build && \
	cd /tmp/build && \
	cmake -DCMAKE_INSTALL_PREFIX=/opt/vexriscv-sca-sdk/cw305-clang \
		-DCMAKE_BUILD_TYPE=Release \
		-DSDK_BUILD_TARGET=CW305 \
		-DSDK_DEFAULT_C_COMPILER=clang \
		/usr/src/vexriscv-sca-sdk && \
	cmake --build . -j$(nproc) && \
	cmake --install . && \
	rm -rf /tmp/build

# Default env
ENV SDK_DIR="/opt/vexriscv-sca-sdk/sakura-x-gcc"

WORKDIR /work

CMD ["/bin/bash"]