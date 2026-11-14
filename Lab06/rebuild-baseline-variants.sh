#!/bin/bash
set -euo pipefail
base=/srv/ak2/kzirx
export ARCH=arm CROSS_COMPILE='ccache arm-none-eabi-'
export PATH=/opt/gcc-arm-10.3-2021.07-x86_64-arm-none-eabi/bin:$PATH
export CCACHE_DIR=$base/lab3/ccache
headers=$base/lab3/build/baseline-headers
mkdir -p "$headers" "$base/lab6-builds/dynamic-debug"
cp "$base/lab6/hello1.ko" "$base/lab6/hello2.ko" "$base/lab6-builds/dynamic-debug/"
cp "$base/lab3/artifacts/kernel-baseline.config" "$headers/.config"
make -C "$base/lab3/sources/linux-4.19.325" O="$headers" HOSTCC=gcc-9 olddefconfig modules_prepare > "$base/lab6/logs/baseline-headers.log" 2>&1
cp "$base/lab3/build/kernel/Module.symvers" "$headers/"
for variant in no-debug define-debug; do
    directory=$base/lab6-builds/$variant
    mkdir -p "$directory/inc"
    cp "$base/lab6/hello1.c" "$base/lab6/hello2.c" "$base/lab6/Makefile" "$base/lab6/Kbuild" "$directory/"
    cp "$base/lab6/inc/hello1.h" "$directory/inc/"
    debug=0
    test "$variant" = define-debug && debug=1
    make -C "$directory" KDIR="$headers" HOSTCC=gcc-9 TRACE_DEBUG="$debug" -j4 > "$base/lab6/logs/rebuild-$variant.log" 2>&1
    mkdir -p "$base/lab6/variants/$variant"
    cp "$directory/hello1.ko" "$directory/hello2.ko" "$base/lab6/variants/$variant/"
done
printf 'BASELINE VARIANTS RESTORED IN SEPARATE BUILD DIRECTORIES\n'
