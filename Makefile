OUTDIR              			= build
PROJECT							= clang
LLVM_PROJ						= llvm-project
ARTIFACTS						= /data/artifacts
CLANG_VERSION = $(shell if [ -d $(ARTIFACTS)/clang ]; then ls -l $(ARTIFACTS)/clang | wc -l; else echo 0; fi)
CLANG_PAST_VER = $(shell ls -1 $(ARTIFACTS)/clang | sort -n | tail -n 1)
REMOTE							= root@77.221.151.187
# LICHIE							= root@ip-addr

STRESSNG_PROJ				= stress-ng
STRESSNG_VER = $(shell if [ -d $(ARTIFACTS)/stress-ng ]; then ls -l $(ARTIFACTS)/stress-ng | wc -l; else echo 0; fi)

.PHONY: build clean build-clang

clean:
	rm -rf $(OUTDIR)
	rm -rf $(STRESSNG_PROJ)
	rm -rf $(LLVM_PROJ)


llvm-project:
	git clone https://github.com/Compiler-assisted-fuzzing/llvm-project.git --depth 1 $(LLVM_PROJ)

build-clang: llvm-project
	docker build -f docker/clang-build.dockerfile -t llvm-builder . || exit 1
	docker run --rm -v $(PWD)/$(LLVM_PROJ):/src llvm-builder || exit 1
	mkdir -p $(ARTIFACTS)/clang/$(CLANG_VERSION)
	cp $(LLVM_PROJ)/install-llvm/bin/clang $(ARTIFACTS)/clang/$(CLANG_VERSION)/clang || exit 1
# Transfer to msk mirror
	ssh $(REMOTE) mkdir -p $(ARTIFACTS)/clang/$(CLANG_VERSION) || exit 1
	scp $(ARTIFACTS)/clang/$(CLANG_VERSION)/clang $(REMOTE):$(ARTIFACTS)/clang/$(CLANG_VERSION) || exit 1

stress-ng:
	git clone https://github.com/Compiler-assisted-fuzzing/stress-ng.git --depth 1 $(STRESSNG_PROJ)

GCC_TOOLCHAIN = /root/semaphore/tmp/repository_1_1/llvm-project/build/bin/sc-dt/riscv-gcc
LLVM_BIN	  = /root/semaphore/tmp/repository_1_1/llvm-project/build/bin

build-stress-ng: stress-ng
	docker build --build-arg SEED=$$(python3 -c "import random; print(random.randint(1, 2**64 - 1))") \
	--build-arg FUZZ=bpu \
	-f docker/stress-ng-build.dockerfile -t stress-ng-builder . || exit 1
	docker run --rm -v $(GCC_TOOLCHAIN):/src/gcc -v $(LLVM_BIN):/src/llvm/bin stress-ng-builder
	rm -rf $(STRESSNG_PROJ)

# mkdir -p $(ARTIFACTS)/$(STRESSNG_PROJ)/$(STRESSNG_VER) || exit 1
# cp $(STRESSNG_PROJ)/$(STRESSNG_PROJ) $(ARTIFACTS)/$(STRESSNG_PROJ)/$(STRESSNG_VER)/$(STRESSNG_PROJ) || exit 1
# Transfer to msk mirror
# ssh $(REMOTE) mkdir -p $(ARTIFACTS)/$(STRESSNG_PROJ)/$(STRESSNG_VER) || exit 1
# scp $(ARTIFACTS)/$(STRESSNG_PROJ)/$(STRESSNG_VER)/$(STRESSNG_PROJ) $(REMOTE):$(ARTIFACTS)/$(STRESSNG_PROJ)/$(STRESSNG_VER) || exit 1
# ssh $(LICHIE) mkdir -p $(ARTIFACTS)/$(STRESSNG_PROJ)/$(STRESSNG_VER)
# scp $(ARTIFACTS)/$(STRESSNG_PROJ)/$(STRESSNG_VER)/$(STRESSNG_PROJ) $(LICHIE):$(ARTIFACTS)/$(STRESSNG_PROJ)/$(STRESSNG_VER)
