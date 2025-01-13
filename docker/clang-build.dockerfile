FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    git \
    cmake \
    ninja-build \
    build-essential \
    python3 \
    python3-pip \
    wget \
    lsb-release \
    software-properties-common \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# WORKDIR /src
# RUN git clone https://github.com/Compiler-assisted-fuzzing/llvm-project.git --depth 1 /src

WORKDIR /src/build

CMD cmake -G Ninja \
      -DLLVM_ENABLE_PROJECTS="clang" \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=../install-llvm \
      -DLLVM_TARGETS_TO_BUILD="RISCV" \
      -DLLVM_BUILD_EXAMPLES=OFF \
      -DLLVM_BUILD_TESTS=OFF \
      ../llvm \
    && ninja -j4 \
    && ninja install