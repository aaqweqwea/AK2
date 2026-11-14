#!/bin/sh
cd /mnt/host/lab6 || exit 1
echo 'Baseline kernel:'
uname -r
ls -d /sys/kernel/debug/dynamic_debug
for variant in no-debug define-debug; do
    echo "Testing $variant"
    insmod "variants/$variant/hello1.ko"
    insmod "variants/$variant/hello2.ko" count=2
    rmmod hello2
    rmmod hello1
done
