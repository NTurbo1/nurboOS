ifdef HOST
	
HOSTARCH?=$(shell ../target_triplet_to_arch.sh $(HOST))
KERNEL_BIN?=nurbo_$(HOSTARCH).bin

CFLAGS?=-O2 -g
CPPFLAGS?=
LDFLAGS?=
LIBS?=

DEST_DIR?=
PREFIX?=/usr/local
EXEC_PREFIX?=$(PREFIX)
BOOT_DIR?=$(EXEC_PREFIX)/boot
INCLUDE_DIR?=$(PREFIX)/include

CFLAGS:=$(CFLAGS) -ffreestanding -Wall -Wextra
CPPFLAGS:=$(CPPFLAGS) -D__is_kernel -Iinclude
LDFLAGS:=$(LDFLAGS)
LIBS:=$(LIBS) -nostdlib -lk -lgcc

ARCH_DIR=arch/$(HOSTARCH)

include $(ARCH_DIR)/make.config

CFLAGS:=$(CFLAGS) $(KERNEL_ARCH_CFLAGS)
CPPFLAGS:=$(CPPFLAGS) $(KERNEL_ARCH_CPPFLAGS)
LDFLAGS:=$(LDFLAGS) $(KERNEL_ARCH_LDFLAGS)
LIBS:=$(LIBS) $(KERNEL_ARCH_LIBS)

KERNEL_OBJS=\
$(KERNEL_ARCH_OBJS) \
kernel/kernel.o \

OBJS=\
$(ARCH_DIR)/crti.o \
$(ARCH_DIR)/crtbegin.o \
$(KERNEL_OBJS) \
$(ARCH_DIR)/crtend.o \
$(ARCH_DIR)/crtn.o \

LINK_LIST=\
$(LDFLAGS) \
$(ARCH_DIR)/crti.o \
$(ARCH_DIR)/crtbegin.o \
$(KERNEL_OBJS) \
$(LIBS) \
$(ARCH_DIR)/crtend.o \
$(ARCH_DIR)/crtn.o \

.PHONY: all clean install install-headers install-kernel
.SUFFIXES: .o .c .S

all: $(KERNEL_BIN)

$(KERNEL_BIN): $(OBJS) $(ARCH_DIR)/linker.ld
	$(CC) -T $(ARCH_DIR)/linker.ld -o $@ $(CFLAGS) $(LINK_LIST)
	grub2-file --is-x86-multiboot $(KERNEL_BIN)

$(ARCH_DIR)/crtbegin.o $(ARCH_DIR)/crtend.o:
	OBJ=`$(CC) $(CFLAGS) $(LDFLAGS) -print-file-name=$(@F)` && cp "$$OBJ" $@

.c.o:
	$(CC) -MD -c $< -o $@ -std=gnu11 $(CFLAGS) $(CPPFLAGS)

.S.o:
	$(CC) -MD -c $< -o $@ $(CFLAGS) $(CPPFLAGS)

clean:
	rm -f $(KERNEL_BIN)
	rm -f $(OBJS) *.o */*.o */*/*.o
	rm -f $(OBJS:.o=.d) *.d */*.d */*/*.d

install: install-headers install-kernel

install-headers:
	mkdir -p $(DEST_DIR)$(INCLUDE_DIR)
	cp -R --preserve=timestamps include/. $(DEST_DIR)$(INCLUDE_DIR)/.

install-kernel: $(KERNEL_BIN)
	mkdir -p $(DEST_DIR)$(BOOT_DIR)
	cp $(KERNEL_BIN) $(DEST_DIR)$(BOOT_DIR)

-include $(OBJS:.o=.d)

else 
	error "ERROR: HOST is not defined!"
endif
