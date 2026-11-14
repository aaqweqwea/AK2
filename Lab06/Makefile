KDIR ?= /srv/ak2/kzirx/lab3/build/kernel
ARCH ?= arm
CROSS_COMPILE ?= arm-none-eabi-

.PHONY: all clean
all:
	$(MAKE) -C "$(KDIR)" M="$(CURDIR)" ARCH="$(ARCH)" CROSS_COMPILE="$(CROSS_COMPILE)" modules

clean:
	$(MAKE) -C "$(KDIR)" M="$(CURDIR)" ARCH="$(ARCH)" CROSS_COMPILE="$(CROSS_COMPILE)" clean
