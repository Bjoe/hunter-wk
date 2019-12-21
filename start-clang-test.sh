#!/bin/bash

export TOOLCHAIN=clang-cxx17
export POLLY_DIR=/home/jboehme/Development/polly

docker/start-test.sh $@