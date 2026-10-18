#!/bin/bash
set -euo pipefail
base=/srv/ak2/kzirx/lab3
export ARCH=arm
export PATH=/opt/gcc-arm-10.3-2021.07-x86_64-arm-none-eabi/bin:/opt/gcc-arm-10.3-2021.07-x86_64-arm-none-linux-gnueabihf/bin:$PATH
export CROSS_COMPILE=arm-none-eabi-
root=$base/rootfs
test -x "$root/bin/busybox"
mkdir -p "$root"/{boot,dev,etc/init.d,lib,proc,root,sys/kernel/debug,tmp,mnt/host}
make -C "$base/build/kernel" HOSTCC=gcc-9 INSTALL_MOD_PATH="$root" modules_install > "$base/logs/modules-install.log" 2>&1
cp "$base/build/kernel/arch/arm/boot/zImage" "$root/boot/"
cp "$base/build/kernel/arch/arm/boot/dts/am335x-boneblack.dtb" "$base/build/kernel/System.map" "$root/boot/"
cp "$base/build/kernel/.config" "$root/boot/config"
libc_dir=$(arm-none-linux-gnueabihf-gcc -print-sysroot)/lib
cp -a "$libc_dir/"*.so* "$root/lib/"
ln -sfn bin/busybox "$root/init"
cat > "$root/etc/init.d/rcS" <<'EOF'
#!/bin/sh
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev
mount -t debugfs debugfs /sys/kernel/debug
echo /sbin/mdev > /proc/sys/kernel/hotplug
mdev -s
echo 8 > /proc/sys/kernel/printk
hostname arm-kzirx
mount -t 9p -o trans=virtio,ro hostshare /mnt/host
echo 'AK2 ARM environment ready'
EOF
chmod +x "$root/etc/init.d/rcS"
cat > "$root/etc/inittab" <<'EOF'
::sysinit:/etc/init.d/rcS
::respawn:-/bin/sh
::ctrlaltdel:/sbin/reboot
EOF
printf '%s\n' '$MODALIAS=.* root:root 660 @modprobe "$MODALIAS"' > "$root/etc/mdev.conf"
printf 'root:x:0:0:root:/root:/bin/sh\n' > "$root/etc/passwd"
printf 'root:x:0:\n' > "$root/etc/group"
printf '127.0.0.1 localhost\n' > "$root/etc/hosts"
for lab in 4 5 6; do
    cd "/srv/ak2/kzirx/lab$lab"
    mkdir -p logs
    make HOSTCC=gcc-9 -j4 > logs/build.log 2>&1
    for file in *.c inc/*.h; do
        test -f "$file" || continue
        "$base/sources/linux-4.19.325/scripts/checkpatch.pl" --no-tree -f "$file" > "logs/checkpatch-$(basename "$file").log" 2>&1 || true
    done
    ! grep -h '^ERROR:' logs/checkpatch-*.log
    sha256sum *.c *.ko Kbuild Makefile > logs/build.sha256
done
cd /srv/ak2/kzirx/lab6
mkdir -p variants/no-debug variants/define-debug
cp hello1.ko hello2.ko variants/no-debug/
make HOSTCC=gcc-9 clean > logs/define-debug-build.log 2>&1
make HOSTCC=gcc-9 TRACE_DEBUG=1 -j4 >> logs/define-debug-build.log 2>&1
cp hello1.ko hello2.ko variants/define-debug/
cd "$root"
fakeroot bash -c 'test -e dev/console || mknod dev/console c 5 1; test -e dev/null || mknod dev/null c 1 3; find . -print0 | cpio --null -o -H newc --owner=0:0 2>../logs/cpio.log | gzip -1 > ../artifacts/rootfs-baseline.cpio.gz'
sha256sum "$base/artifacts/"* > "$base/logs/platform-artifacts.sha256"
printf 'ROOTFS AND MODULES READY\n'
