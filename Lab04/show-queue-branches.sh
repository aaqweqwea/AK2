#!/bin/sh
cd /mnt/host/lab4 || exit 1
insmod hello.ko count=0
rmmod hello
insmod hello.ko count=5
cat /sys/module/hello/parameters/count
rmmod hello
insmod hello.ko count=11
lsmod
