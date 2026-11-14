#!/bin/sh
cd /mnt/host/lab6 || exit 1
control=/sys/kernel/debug/dynamic_debug/control
insmod hello1.ko
insmod hello2.ko count=2
echo 'Only the record-printing source line is enabled:'
echo 'module hello1 =_' > "$control"
line=$(grep 'record %u:' "$control" | grep hello1.c | head -1 | cut -d: -f2 | cut -d' ' -f1)
echo "module hello1 line $line +pfm" > "$control"
grep hello1.c "$control" | cut -d' ' -f1-3
echo 'Loaded section addresses:'
for section in .text .exit.text .rodata; do
    printf '%s: ' "$section"
    cat "/sys/module/hello1/sections/$section"
done
rmmod hello2
rmmod hello1
