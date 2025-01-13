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
    # disable libc download when ger rid of problems with sysroot
    # libc6-dev \
    && rm -rf /var/lib/apt/lists/*

# uncomment when ger rid of problems with sysroot
# COPY llvm-project/build/bin/clang-20 /usr/bin/
# COPY llvm-project/build/lib/clang/20/include /usr/include/

WORKDIR /src

CMD STATIC=1 TARGET=x86-64 make -j $(nproc)
#
# CMD make clean && STATIC=1 CC=clang-20 CXX=clang-20 make -j $(nproc)
