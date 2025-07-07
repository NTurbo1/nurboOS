#!/bin/sh
KERNEL_BIN=x86_32-kernel.bin
GRUB_CFG_DIR=boot/grub2

ISO_DIR=iso
ISO_BOOT_DIR=$ISO_DIR/boot
ISO_BOOT_GRUB_DIR=$ISO_BOOT_DIR/grub
ISO_OUTPUT=x86_32-nurbo-os.iso

echo "INFO: checking multiboot header..."

if grub2-file --is-x86-multiboot $KERNEL_BIN; then
  echo "INFO: multiboot confirmed"
else
  echo "ERROR: the file is not multiboot" >&2
  exit 1
fi

echo "mkdir -p $ISO_BOOT_GRUB_DIR"
mkdir -p $ISO_BOOT_GRUB_DIR

echo "cp $KERNEL_BIN $ISO_BOOT_DIR/$KERNEL_BIN"
cp $KERNEL_BIN $ISO_BOOT_DIR/$KERNEL_BIN

echo "cp $GRUB_CFG_DIR/grub.cfg $ISO_BOOT_GRUB_DIR/grub.cfg"
cp $GRUB_CFG_DIR/grub.cfg $ISO_BOOT_GRUB_DIR/grub.cfg

echo "grub2-mkrescue -o $ISO_OUTPUT $ISO_DIR" 
grub2-mkrescue -o $ISO_OUTPUT $ISO_DIR

