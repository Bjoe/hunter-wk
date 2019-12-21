#!/bin/bash

export TOOLCHAIN=gcc-7-cxx17
export POLLY_DIR=/home/jboehme/Development/polly

docker/start-test.sh $@