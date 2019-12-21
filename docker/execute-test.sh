#!/bin/bash

groupmod -g $2 developer
usermod -u $1 -g $2 developer

set -x

su developer -c "\
  export PATH=\"/polly/bin:\$PATH\" && \
  export TOOLCHAIN=$3 && \
  export PROJECT_DIR=examples/$4 && \
  # Older NDKs has a dependency to ncurses5
  sudo ln -s /lib/x86_64-linux-gnu/libncurses.so.6 /lib/x86_64-linux-gnu/libncurses.so.5 && \
  sudo ln -s /lib/x86_64-linux-gnu/libtinfo.so.6 /lib/x86_64-linux-gnu/libtinfo.so.5 && \
  cd /build && \
  install-ci-dependencies.py && \
  export PATH=\"`pwd`/_ci/cmake/bin:\${PATH}\" && \
  export ANDROID_NDK_r10e=\"`pwd`/_ci/android-ndk-r10e\" && \
  export ANDROID_NDK_r11c=\"`pwd`/_ci/android-ndk-r11c\" && \
  export ANDROID_NDK_r15c=\"`pwd`/_ci/android-ndk-r15c\" && \
  export ANDROID_NDK_r16b=\"`pwd`/_ci/android-ndk-r16b\" && \
  export ANDROID_NDK_r17=\"`pwd`/_ci/android-ndk-r17\" && \
  cd /source/hunter && \
  python3 ./jenkins.py
"
su developer -c /bin/bash
#/bin/bash
#cd /source/hunter/docs
#source ./jenkins.sh
#./make.sh

/bin/bash
