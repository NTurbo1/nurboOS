#!/bin/sh
set -e
. ./config_x86.sh

for PROJECT in $PROJECTS; do
  (cd $PROJECT && $MAKE clean)
done

rm -rf $SYSROOT 
rm -rf $ISO_DIR
rm -rf $ISO
