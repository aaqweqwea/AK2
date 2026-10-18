#!/bin/bash
set -euo pipefail
base=/srv/ak2/kzirx/lab3
exec qemu-system-arm -machine virt -cpu cortex-a15 -m 768 -nographic \
    -kernel "$base/rootfs/boot/zImage" \
    -netdev user,id=n0 -device virtio-net-device,netdev=n0 \
    -fsdev local,id=ownfiles,path=/srv/ak2/kzirx,security_model=none,readonly=on \
    -device virtio-9p-device,fsdev=ownfiles,mount_tag=hostshare \
    -append 'root=/dev/nfs nfsroot=10.0.2.2:/srv/ak2/kzirx/lab3/rootfs,vers=3,tcp,nolock,port=2049,mountport=20048 ip=dhcp rw console=ttyAMA0,115200 nfsrootdebug'
