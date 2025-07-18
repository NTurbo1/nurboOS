#!/bin/sh
set -e
. ./build_x86.sh

echo "INFO: checking multiboot header..."

if grub2-file --is-x86-multiboot $SYSROOT/boot/$KERNEL_BIN; then
  echo "INFO: multiboot confirmed"
else
  echo "ERROR: the file is not multiboot" >&2
  exit 1
fi

mkdir -p $ISO_DIR
mkdir -p $ISO_DIR/boot
mkdir -p $ISO_DIR/boot/grub

cp $SYSROOT/boot/$KERNEL_BIN $ISO_DIR/boot/$KERNEL_BIN
cat > $ISO_DIR/boot/grub/grub.cfg << EOF
menuentry "Nurbo" {
	multiboot /boot/$KERNEL_BIN
}
EOF
grub2-mkrescue -o $ISO $ISO_DIR
