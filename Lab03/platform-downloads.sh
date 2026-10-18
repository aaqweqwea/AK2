#!/bin/bash
set -euo pipefail
workspace=/srv/ak2/kzirx/lab3
mkdir -p "$workspace"/{downloads,sources,build,logs,artifacts}
cd "$workspace/downloads"
fetch() {
    curl --fail --location --silent --show-error --retry 2 \
        --connect-timeout 15 --max-time 240 "$1" -o "$2"
}
fetch https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.19.325.tar.xz linux-4.19.325.tar.xz
fetch https://cdn.kernel.org/pub/linux/kernel/v4.x/sha256sums.asc kernel-sha256sums.asc
grep ' linux-4.19.325.tar.xz$' kernel-sha256sums.asc | sha256sum -c -
fetch https://codeload.github.com/u-boot/u-boot/tar.gz/refs/tags/v2019.07 u-boot-v2019.07.tar.gz
fetch https://patchwork.ozlabs.org/series/130450/mbox/ uboot-130450.mbox
fetch https://busybox.net/downloads/busybox-1.31.1.tar.bz2 busybox-1.31.1.tar.bz2
fetch https://github.com/mirror/busybox/commit/d3539be8f27b8cbfdfee460fe08299158f08bcd9.patch busybox-stime.patch
sha256sum *.tar.* *.mbox *.patch > ../logs/downloads.sha256
tar -xJf linux-4.19.325.tar.xz -C ../sources
tar -xzf u-boot-v2019.07.tar.gz -C ../sources
tar -xjf busybox-1.31.1.tar.bz2 -C ../sources
file ../sources/linux-4.19.325/Makefile ../sources/u-boot-2019.07/Makefile ../sources/busybox-1.31.1/Makefile
