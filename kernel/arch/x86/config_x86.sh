#!/bin/sh
set -e

readonly i386_elf=i386-elf
readonly x86_64_elf=x86_64-elf

if [ -z "$HOST" ]; then
    echo "ERROR: Define the 'HOST' variable! 
    Available options:
    - $i386_elf
    - $x86_64_elf

    Supported hosts:
    - $i386_elf" >&2
    exit 1
fi

export KERNEL_DIR="kernel"
export HOSTARCH=$(./target_triplet_to_arch.sh $HOST)
export KERNEL_BIN=nurbo_$HOSTARCH.bin
export ISO=nurbo_$HOSTARCH.iso
export ISO_DIR=iso

if [[ $HOST = $i386_elf ]]; then
    echo "Host is set to $i386_elf"
elif [[ $HOST = $x86_64_elf ]]; then 
    echo "ERROR: $x86_64_elf is not supported yet!" >&2
    exit 1
else 
    echo "ERROR: $HOST is not supported or unknown!" >&2
    exit 1
fi

SYSTEM_HEADER_PROJECTS="libc $KERNEL_DIR"
PROJECTS="libc $KERNEL_DIR"

export MAKE=${MAKE:-make}

export AR=${HOST}-ar
export AS=${HOST}-as
export CC=${HOST}-gcc

export PREFIX=/usr
export EXEC_PREFIX=$PREFIX
export BOOT_DIR=/boot
export LIBDIR=$EXEC_PREFIX/lib
export INCLUDE_DIR=$PREFIX/include

export CFLAGS='-O2 -g'
export CPPFLAGS=''

# Configure the cross-compiler to use the desired system root.
export SYSROOT="$(pwd)/sysroot"
export CC="$CC --sysroot=$SYSROOT"

# Work around that the -elf gcc targets doesn't have a system include directory
# because it was configured with --without-headers rather than --with-sysroot.
if echo "$HOST" | grep -Eq -- '-elf($|-)'; then
  export CC="$CC -isystem=$INCLUDE_DIR"
fi
