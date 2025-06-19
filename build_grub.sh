#!/bin/bash
mkdir -p $HOME/opt
cd $HOME/opt
wget https://ftp.gnu.org/gnu/grub/grub-2.12.tar.gz
zcat grub-2.12.tar.gz | tar xvf -

cd grub-2.12
./configure
make install
