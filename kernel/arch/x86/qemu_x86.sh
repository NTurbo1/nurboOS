#!/bin/sh
set -e
. ./iso_x86.sh

qemu-system-$HOSTARCH -cdrom $ISO
