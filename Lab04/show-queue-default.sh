#!/bin/sh
cd /mnt/host/lab4 || exit 1
modinfo hello.ko
insmod hello.ko
cat /sys/module/hello/parameters/count
rmmod hello
