#!/usr/bin/env bash
set -euo pipefail
base=/srv/ak2/kzirx/lab3
export ARCH=arm
export PATH=/opt/gcc-arm-10.3-2021.07-x86_64-arm-none-eabi/bin:/opt/gcc-arm-10.3-2021.07-x86_64-arm-none-linux-gnueabihf/bin:$PATH
export CCACHE_DIR=$base/ccache
export KBUILD_BUILD_USER=kzirx KBUILD_BUILD_HOST=Ubuntu24
export CROSS_COMPILE='ccache arm-none-eabi-'
mkdir -p "$base"/{build/kernel,build/uboot,build/busybox,artifacts,logs,rootfs}
ccache -M 2G
cd "$base/sources/linux-4.19.325"
cat > "$base/build/bbb.cfg" <<'EOF'
CONFIG_USB_ANNOUNCE_NEW_DEVICES=y
CONFIG_USB_EHCI_ROOT_HUB_TT=y
CONFIG_AM335X_PHY_USB=y
CONFIG_USB_MUSB_TUSB6010=y
CONFIG_USB_MUSB_OMAP2PLUS=y
CONFIG_USB_MUSB_HDRC=y
CONFIG_USB_MUSB_DSPS=y
CONFIG_USB_MUSB_AM35X=y
CONFIG_USB_CONFIGFS=y
CONFIG_NOP_USB_XCEIV=y
CONFIG_USB_HID=y
CONFIG_USB_HIDDEV=y
CONFIG_USB_SERIAL=y
CONFIG_USB_SERIAL_PL2303=y
CONFIG_USB_SERIAL_GENERIC=y
CONFIG_USB_SERIAL_SIMPLE=y
CONFIG_USB_SERIAL_FTDI_SIO=y
CONFIG_USB_ULPI=y
CONFIG_USB_ULPI_BUS=y
CONFIG_BRIDGE=y
CONFIG_OF_OVERLAY=y
CONFIG_LOCALVERSION="-kzirx"
# CONFIG_LOCALVERSION_AUTO is not set
# CONFIG_DYNAMIC_DEBUG is not set
CONFIG_DEBUG_FS=y
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_NET_9P=y
CONFIG_NET_9P_VIRTIO=y
CONFIG_9P_FS=y
CONFIG_NFS_FS=y
CONFIG_NFS_V3=y
CONFIG_ROOT_NFS=y
CONFIG_IP_PNP=y
CONFIG_IP_PNP_DHCP=y
CONFIG_VIRTIO_NET=y
EOF
make O="$base/build/kernel" HOSTCC=gcc-9 multi_v7_defconfig > "$base/logs/kernel-config.log" 2>&1
scripts/kconfig/merge_config.sh -m -O "$base/build/kernel" "$base/build/kernel/.config" "$base/build/bbb.cfg" >> "$base/logs/kernel-config.log" 2>&1
make O="$base/build/kernel" HOSTCC=gcc-9 olddefconfig >> "$base/logs/kernel-config.log" 2>&1
date -u +%FT%TZ > "$base/logs/kernel-build-start.txt"
make O="$base/build/kernel" HOSTCC=gcc-9 -j6 zImage modules am335x-boneblack.dtb > "$base/logs/kernel-build.log" 2>&1
date -u +%FT%TZ > "$base/logs/kernel-build-end.txt"
cp "$base/build/kernel/arch/arm/boot/zImage" "$base/artifacts/zImage-baseline"
cp "$base/build/kernel/.config" "$base/artifacts/kernel-baseline.config"
printf 'KERNEL COMPLETE\n'

cd "$base/sources/u-boot-2019.07"
python3 - "$base/downloads/uboot-130450.mbox" <<'PY'
import mailbox, subprocess, sys
for message in mailbox.mbox(sys.argv[1]):
    payload=message.get_payload(decode=True)
    if not payload: continue
    subprocess.run(['patch','-p1','--forward'],input=payload,check=True)
PY
make O="$base/build/uboot" HOSTCC=gcc-9 am335x_boneblack_defconfig > "$base/logs/uboot-build.log" 2>&1
make O="$base/build/uboot" HOSTCC=gcc-9 -j6 >> "$base/logs/uboot-build.log" 2>&1
cp "$base/build/uboot/MLO" "$base/build/uboot/u-boot.img" "$base/artifacts/"
printf 'UBOOT COMPLETE\n'

cd "$base/sources/busybox-1.31.1"
sed 's/bb_simple_/bb_/g' "$base/downloads/busybox-stime.patch" > "$base/build/busybox-stime-1.31.1.patch"
patch -p1 < "$base/build/busybox-stime-1.31.1.patch" > "$base/logs/busybox-patch.log"
export CROSS_COMPILE='ccache arm-none-linux-gnueabihf-'
make O="$base/build/busybox" HOSTCC=gcc-9 defconfig > "$base/logs/busybox-build.log" 2>&1
make O="$base/build/busybox" HOSTCC=gcc-9 -j6 >> "$base/logs/busybox-build.log" 2>&1
make O="$base/build/busybox" HOSTCC=gcc-9 CONFIG_PREFIX="$base/rootfs" install >> "$base/logs/busybox-build.log" 2>&1
printf 'BUSYBOX COMPLETE\n'
