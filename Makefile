OUTDIR              			= build
PROJECT							= clang
LLVM_PROJ						= llvm-project
ARTIFACTS						= /data/artifacts
CLANG_VERSION					= $(shell ls -l /data/clang | wc -l)
REMOTE							= root@77.221.151.187
# LICHIE							= root@ip-addr

STRESSNG_PROJ				= stress-ng
STRESSNG_VER				= $(shell ls -l /data/stress-ng | wc -l)

.PHONY: build clean build-clang

clean:
	rm -rf $(OUTDIR)
	rm -rf $(STRESSNG_PROJ)
	rm -rf $(LLVM_PROJ)


llvm-project:
	git clone https://github.com/Compiler-assisted-fuzzing/llvm-project.git --depth 1 $(LLVM_PROJ)

build-clang: llvm-project
	docker build -f docker/clang-build.dockerfile -t llvm-builder .
	docker run --rm -v $(PWD)/$(LLVM_PROJ):/src llvm-builder
# mkdir -p $(ARTIFACTS)/clang/$(CLANG_VERSION)
# cp $(LLVM_PROJ)/build/bin/clang-20 $(ARTIFACTS)/clang/$(CLANG_VERSION)/clang
# ssh $(REMOTE) mkdir -p $(ARTIFACTS)/clang/$(CLANG_VERSION)
# ssh $(LICHIE) mkdir -p $(ARTIFACTS)/clang/$(CLANG_VERSION)
# scp $(ARTIFACTS)/clang/$(CLANG_VERSION)/clang $(REMOTE):$(ARTIFACTS)/clang/$(CLANG_VERSION)
# scp $(ARTIFACTS)/clang/$(CLANG_VERSION)/clang $(LICHIE):$(ARTIFACTS)/clang/$(CLANG_VERSION)

stress-ng:
	git clone https://github.com/Compiler-assisted-fuzzing/stress-ng.git --depth 1 $(STRESSNG_PROJ)

build-stress-ng: stress-ng
	docker build -f docker/stress-ng-build.dockerfile -t stress-ng-builder .
	docker run --rm -v $(PWD)/$(STRESSNG_PROJ):/src stress-ng-builder
	mkdir -p $(ARTIFACTS)/stress-ng/$(STRESSNG_VER)
	cp $(STRESSNG_PROJ)/$(STRESSNG_PROJ) $(ARTIFACTS)/$(STRESSNG_PROJ)/$(STRESSNG_VER)/$(STRESSNG_PROJ)
	ssh $(REMOTE) mkdir -p $(ARTIFACTS)/$(STRESSNG_PROJ)/$(STRESSNG_VER)
# ssh $(LICHIE) mkdir -p $(ARTIFACTS)/$(STRESSNG_PROJ)/$(STRESSNG_VER)
	scp $(ARTIFACTS)/$(STRESSNG_PROJ)/$(STRESSNG_VER)/$(STRESSNG_PROJ) $(REMOTE):$(ARTIFACTS)/$(STRESSNG_PROJ)/$(STRESSNG_VER)
# scp $(ARTIFACTS)/$(STRESSNG_PROJ)/$(STRESSNG_VER)/$(STRESSNG_PROJ) $(LICHIE):$(ARTIFACTS)/$(STRESSNG_PROJ)/$(STRESSNG_VER)
