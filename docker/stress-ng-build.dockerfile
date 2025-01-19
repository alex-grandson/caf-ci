FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Установка необходимых зависимостей
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

# Объявление переменных аргументов для параметризации
ARG SEED=1737299106422640664
ARG FUZZ=bpu

# Рабочая директория
WORKDIR /src

# Указание команды с использованием аргументов
CMD CFLAGS="--fseed=${SEED} --fuzz=${FUZZ} --target=riscv64-unknown-linux-gnu \
    --gcc-toolchain=/src/gcc \
    --sysroot=/src/gcc/sysroot" \
    CC="/src/llvm/bin/clang" \
    CXX="/src/llvm/bin/clang++ -v" STATIC=1 make -j12