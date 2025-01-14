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

build-stress-ng: stress-ng
	chmod -R 755 $(ARTIFACTS)/clang/$(CLANG_PAST_VER)/clang
	docker build -f docker/stress-ng-build.dockerfile -t stress-ng-builder .
	docker run --rm -v $(PWD)/$(STRESSNG_PROJ):/src -v /root/semaphore/riscv-gcc/:/gcc -v $(ARTIFACTS)/clang/$(CLANG_PAST_VER)/clang:/artifacts/clang --user $(id -u):$(id -g) stress-ng-builder || exit 1
	mkdir -p $(ARTIFACTS)/$(STRESSNG_PROJ)/$(STRESSNG_VER) || exit 1
	cp $(STRESSNG_PROJ)/$(STRESSNG_PROJ) $(ARTIFACTS)/$(STRESSNG_PROJ)/$(STRESSNG_VER)/$(STRESSNG_PROJ) || exit 1
	rm -rf $(STRESSNG_PROJ) || exit 1
# Transfer to msk mirror
	ssh $(REMOTE) mkdir -p $(ARTIFACTS)/$(STRESSNG_PROJ)/$(STRESSNG_VER) || exit 1
	scp $(ARTIFACTS)/$(STRESSNG_PROJ)/$(STRESSNG_VER)/$(STRESSNG_PROJ) $(REMOTE):$(ARTIFACTS)/$(STRESSNG_PROJ)/$(STRESSNG_VER) || exit 1
# ssh $(LICHIE) mkdir -p $(ARTIFACTS)/$(STRESSNG_PROJ)/$(STRESSNG_VER)
# scp $(ARTIFACTS)/$(STRESSNG_PROJ)/$(STRESSNG_VER)/$(STRESSNG_PROJ) $(LICHIE):$(ARTIFACTS)/$(STRESSNG_PROJ)/$(STRESSNG_VER)
