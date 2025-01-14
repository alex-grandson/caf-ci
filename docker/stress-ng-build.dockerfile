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
    zlib1g-dev \
    libbsd-dev \
    libattr1-dev  \
    libkeyutils-dev \
    libapparmor-dev \
    apparmor \
    libaio-dev \
    libcap-dev \
    libsctp-dev \
    libgcrypt20-dev \
    libjudy-dev \
    libatomic1 \
    libipsec-mb-dev \
    && rm -rf /var/lib/apt/lists/*

RUN export CFLAGS="--target=riscv64-unknown-linux-gnu \
                    --gcc-toolchain=/gcc \
                    --sysroot=/gcc/sysroot/ \
                    --fuzz=all"

RUN export CC="/artifacts/clang"

RUN export CXX="/artifacts/clang"

WORKDIR /src

CMD STATIC=1 make -j$(nproc)
