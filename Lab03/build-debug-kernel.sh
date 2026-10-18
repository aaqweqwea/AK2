#!/bin/bash
set -euo pipefail
base=/srv/ak2/kzirx/lab3
export ARCH=arm CROSS_COMPILE='ccache arm-none-eabi-'
export PATH=/opt/gcc-arm-10.3-2021.07-x86_64-arm-none-eabi/bin:$PATH
export CCACHE_DIR=$base/ccache
export KBUILD_BUILD_USER=kzirx KBUILD_BUILD_HOST=Ubuntu24
cd "$base/sources/linux-4.19.325"
scripts/config --file "$base/build/kernel/.config" -e DYNAMIC_DEBUG
make O="$base/build/kernel" HOSTCC=gcc-9 olddefconfig > "$base/logs/debug-config.log" 2>&1
date -u +%FT%TZ > "$base/logs/debug-build-start.txt"
make O="$base/build/kernel" HOSTCC=gcc-9 -j6 zImage modules am335x-boneblack.dtb > "$base/logs/debug-build.log" 2>&1
date -u +%FT%TZ > "$base/logs/debug-build-end.txt"
cp "$base/build/kernel/arch/arm/boot/zImage" "$base/artifacts/zImage-dynamic-debug"
cp "$base/build/kernel/.config" "$base/artifacts/kernel-debug.config"
cp "$base/artifacts/zImage-dynamic-debug" "$base/rootfs/boot/zImage"
cp "$base/artifacts/kernel-debug.config" "$base/rootfs/boot/config"
make O="$base/build/kernel" HOSTCC=gcc-9 INSTALL_MOD_PATH="$base/rootfs" modules_install > "$base/logs/debug-modules-install.log" 2>&1
cd /srv/ak2/kzirx/lab6
make HOSTCC=gcc-9 clean > logs/dynamic-debug-build.log 2>&1
make HOSTCC=gcc-9 -j4 >> logs/dynamic-debug-build.log 2>&1
mkdir -p variants/dynamic-debug
cp hello1.ko hello2.ko variants/dynamic-debug/
sha256sum hello1.ko hello2.ko "$base/rootfs/boot/zImage" > logs/dynamic-build.sha256
printf 'DYNAMIC DEBUG KERNEL AND MODULES READY\n'
