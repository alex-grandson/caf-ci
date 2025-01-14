#!/bin/sh
set -e  # Exit immediately if a command exits with a non-zero status

make build-clang
rm -rf llvm-project
