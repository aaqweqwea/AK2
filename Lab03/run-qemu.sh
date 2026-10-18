#!/bin/bash
set -euo pipefail
base=/srv/ak2/kzirx/lab3
exec qemu-system-arm -machine virt -cpu cortex-a15 -m 768 -nographic \
    -kernel "$base/artifacts/zImage-baseline" \
    -initrd "$base/artifacts/rootfs-baseline.cpio.gz" \
    -fsdev local,id=ownfiles,path=/srv/ak2/kzirx,security_model=none,readonly=on \
    -device virtio-9p-device,fsdev=ownfiles,mount_tag=hostshare \
    -append 'root=/dev/ram0 rw console=ttyAMA0,115200 rdinit=/init'
