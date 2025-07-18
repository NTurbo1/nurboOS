#!/bin/sh
set -e
. ./config_x86.sh

mkdir -p "$SYSROOT"

for PROJECT in $SYSTEM_HEADER_PROJECTS; do
  (cd $PROJECT && DEST_DIR="$SYSROOT" $MAKE install-headers)
done
