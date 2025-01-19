OUTDIR              			= build
PROJECT							= clang
LLVM_PROJ						= llvm-project
ARTIFACTS						= /data/artifacts
CLANG_VERSION = $(shell if [ -d $(ARTIFACTS)/clang ]; then ls -l $(ARTIFACTS)/clang | wc -l; else echo 0; fi)
CLANG_PAST_VER = $(shell ls -1 $(ARTIFACTS)/clang | sort -n | tail -n 1)
REMOTE							= root@77.221.151.187
LICHIE							= debian@10.8.0.2

STRESSNG_PROJ				= stress-ng
STRESSNG_VER = $(shell if [ -d $(ARTIFACTS)/stress-ng ]; then ls -l $(ARTIFACTS)/stress-ng | wc -l; else echo 0; fi)

# Generate a random SEED
SEED := $(shell python3 -c "import random; print(random.randint(1, 2**64 - 1))")
TARGET := riscv64-unknown-linux-gnu
TOOLCHAIN := /root/semaphore/tmp/sc-dt/riscv-gcc
SYSROOT := $(TOOLCHAIN)/sysroot
CLANG := /root/semaphore/tmp/repository_1_1/llvm-project/build/bin/clang
CLANGXX := $(CLANG)++

LICHIE_COMMAND=ssh -J root@77.221.151.187 debian@10.8.0.2

.PHONY: build clean build-clang build-stress-ng kill-stress-ng

clean:
	rm -rf $(OUTDIR)
	rm -rf $(STRESSNG_PROJ)
	rm -rf $(LLVM_PROJ)

build-clang: clean
	git clone https://github.com/Compiler-assisted-fuzzing/llvm-project.git --depth 1 $(LLVM_PROJ)
	docker build -f docker/clang-build.dockerfile -t llvm-builder . || exit 1
	docker run --rm -v $(PWD)/$(LLVM_PROJ):/src llvm-builder || exit 1
	mkdir -p $(ARTIFACTS)/clang/$(CLANG_VERSION)
	cp $(LLVM_PROJ)/build/bin/clang $(ARTIFACTS)/clang/$(CLANG_VERSION)/clang || exit 1
# Transfer to msk mirror
	ssh $(REMOTE) mkdir -p $(ARTIFACTS)/clang/$(CLANG_VERSION) || exit 1
	scp $(ARTIFACTS)/clang/$(CLANG_VERSION)/clang $(REMOTE):$(ARTIFACTS)/clang/$(CLANG_VERSION) || exit 1

CFLAGS := --fseed=$(SEED) -O0 -fno-pic --fuzz=all --target=$(TARGET) --gcc-toolchain=$(TOOLCHAIN) --sysroot=$(SYSROOT)
CC := $(CLANG)
CXX := $(CLANGXX) -v
STATIC := 1

kill-stress-ng:
	$(LICHIE_COMMAND) './kill.sh' &

build-stress-ng: clean kill-stress-ng
	git clone https://github.com/Compiler-assisted-fuzzing/stress-ng.git --depth 1 $(STRESSNG_PROJ)
	CFLAGS="$(CFLAGS)" CC="$(CC)" CXX="$(CXX)" STATIC="$(STATIC)" $(MAKE) -C $(STRESSNG_PROJ) -j10
	mkdir -p $(ARTIFACTS)/$(STRESSNG_PROJ)/$(STRESSNG_VER) || exit 1
	cp $(STRESSNG_PROJ)/$(STRESSNG_PROJ) $(ARTIFACTS)/$(STRESSNG_PROJ)/$(STRESSNG_VER)/$(STRESSNG_PROJ) || exit 1
# Transfer to msk mirror
	ssh $(REMOTE) mkdir -p $(ARTIFACTS)/$(STRESSNG_PROJ)/$(STRESSNG_VER) || exit 1
	scp $(ARTIFACTS)/$(STRESSNG_PROJ)/$(STRESSNG_VER)/$(STRESSNG_PROJ) $(REMOTE):$(ARTIFACTS)/$(STRESSNG_PROJ)/$(STRESSNG_VER) || exit 1
# Transfer to lichee
	scp -o ProxyJump=$(REMOTE) $(ARTIFACTS)/$(STRESSNG_PROJ)/$(STRESSNG_VER)/$(STRESSNG_PROJ) $(LICHIE):/home/debian || exit 1
	$(LICHIE_COMMAND) './run.sh' &
