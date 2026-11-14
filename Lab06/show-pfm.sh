#!/bin/sh
cd /mnt/host/lab6 || exit 1
control=/sys/kernel/debug/dynamic_debug/control
echo 'Kernel and NFS root:'
uname -r
mount | awk '$3 == "/" {print $1, "on", $3, "type", $5}'
grep CONFIG_DYNAMIC_DEBUG /boot/config
insmod hello1.ko
insmod hello2.ko count=1
echo 'Enable p, f and m for the entire hello1 module:'
echo 'module hello1 =pfm' > "$control"
grep hello1.c "$control" | cut -d' ' -f1-3
rmmod hello2
rmmod hello1
