#!/bin/bash

BASE_DIR="$( cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd )"
USER_ID="$(id -u)"
GROUP_ID="$(id -g)"

export SRC_DIR=${BASE_DIR}/..
export BUILD_DIR=${BASE_DIR}/../docker-hunter-test-base/build
export DOCKER_HOME=${BASE_DIR}/../docker-hunter-test-base/home

if [ "$1" = "-clean" ]; then
  shift
  rm -fr $BUILD_DIR $SRC_DIR/hunter/_testing
fi
mkdir -p $BUILD_DIR

err=0
if [ -z $TOOLCHAIN ]; then
  echo Please specify TOOLCHAIN env
  err=1
fi

if [ -z $POLLY_DIR ]; then
  echo Please specify POLLY_DIR
  err=1
fi

if [ -z $1 ]; then
  echo Set examples to build like Boost-log
  err=1
fi

if [ $err -gt 0 ]; then
  exit $err;
fi

cp -R ~/.ssh $DOCKER_HOME

mkdir -p $SRC_DIR/hunter/_testing/Hunter
cd $SRC_DIR/hunter
tar --exclude=.git --exclude=_testing -czf $SRC_DIR/hunter/_testing/hunter.tar.gz cmake scripts
cd ${BASE_DIR} 

docker-compose -f $BASE_DIR/docker-compose.yml run --rm hunter-test-build /bin/bash /source/docker/execute-test.sh ${USER_ID} ${GROUP_ID} ${TOOLCHAIN} $1 2>&1 | tee $BUILD_DIR/build.log