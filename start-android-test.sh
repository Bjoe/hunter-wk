#!/bin/bash

export TOOLCHAIN=android-ndk-r17-api-24-arm64-v8a-clang-libcxx14
export POLLY_DIR=/home/jboehme/Development/polly

docker/start-test.sh $@