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

WORKDIR /src

CMD ls /gcc/

# CMD make CFLAGS="--target=riscv64-unknown-linux-gnu --gcc-toolchain=/gcc --sysroot=/gcc/sysroot --fuzz=all"