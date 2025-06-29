# Building GCC and a GCC Cross Compiler for x86_64-elf

This guide documents the exact steps used to build:

- A **host GCC 15.1.0** compiler (latest stable version at the time I built it on my host linux machine)
- A **GCC cross-compiler targeting `x86_64-elf`** for OS development

## ❗ Requirements

Make sure your system has the following dependencies installed:

```
# Debian based
sudo apt update && sudo apt install build-essential bison flex libgmp3-dev libmpc-dev libmpfr-dev texinfo libisl-dev libz-dev

# Fedora
sudo dnf install gcc gcc-c++ make glibc-devel bison flex gmp-devel libmpc-devel mpfr-devel texinfo isl-devel zlib-devel
```

Also make sure you have sufficient disk space (~5–8 GB free).

## Versions
- **Host GCC** - 15.1.0
- **Binutils** - 2.44

## 1. Download Sources
```
mkdir -p $HOME/src && cd $HOME/src

# Download GCC
wget https://ftp.gnu.org/gnu/gcc/gcc-15.1.0/gcc-15.1.0.tar.xz
tar -xf gcc-15.1.0.tar.xz

# Download Binutils
wget https://ftp.gnu.org/gnu/binutils/binutils-2.44.tar.xz
tar -xf binutils-2.44.tar.xz
```

## 2. Build GCC (Can be skipped)
```
export PREFIX="$HOME/opt/gcc-15.1.0"

# Binutils
cd $HOME/src
mkdir build-binutils
cd build-binutils
../binutils-2.44/configure --prefix="$PREFIX" --disable-nls --disable-werror
make -j$(nproc)
make install -j$(nproc)

# GCC
cd $HOME/src

cd gcc-15.1.0
./contrib/download_prerequisites
cd $HOME/src # Returning the main src folder

mkdir build-gcc
cd build-gcc
# You may need to install gcc-multilib (Debian packages) or glibc-devel.i686, libstdc++-devel.i686 (Fedora packages)
../gcc-15.1.0/configure --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --enable-multilib 
make -j$(nproc) # runs pretty long, you can sit back and drink tea :)
make install -j$(nproc)
```

## 3. Build the Cross Compiler
```
export PREFIX="$HOME/opt/cross"
export TARGET=x86_64-elf
export PATH="$PREFIX/bin:$PATH"

# Binutils
cd $HOME/src

mkdir build-binutils
cd build-binutils
../binutils-2.44/configure --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror
make -j$(nproc)
make install -j$(nproc)
```

### GDB (Optional)
It may be worth noting that if you wish to use GDB, and you are running on a different computer architecture than your OS (most common case is developing for ARM on x86_64 or x86_64 on ARM), you need to cross-compile GDB separately. While technically a part of Binutils, it resides in a separate repository.

The protocol for building GDB to target a different architecture is very similar to that of regular Binutils: 
```
../gdb.x.y.z/configure --target=$TARGET --prefix="$PREFIX" --disable-werror
make all-gdb
make install-gdb
```

### Disable Red-Zone (x86_64 specific)
Create the following file and save it as t-x86_64-elf inside gcc/config/i386/ under your GCC sources.
```
# Add libgcc multilib variant without red-zone requirement

MULTILIB_OPTIONS += mno-red-zone
MULTILIB_DIRNAMES += no-red-zone
```
By default this new configuration will not be used by GCC unless it's explicitly told to. Open gcc/config.gcc in your favorite editor and search for case block like this:
```
x86_64-*-elf*)
 	tm_file="${tm_file} i386/unix.h i386/att.h elfos.h newlib-stdint.h i386/i386elf.h i386/x86-64.h"
 	;;
```
This is the target configuration used when creating a GCC Cross-Compiler for x86_64-elf. Modify it to include the new multilib configuration:
```
x86_64-*-elf*)
    tmake_file="${tmake_file} i386/t-x86_64-elf" # include the new multilib configuration
	tm_file="${tm_file} i386/unix.h i386/att.h elfos.h newlib-stdint.h i386/i386elf.h i386/x86-64.h"
	;;
```

### Build GCC Cross Compiler
```
cd $HOME/src

# The $PREFIX/bin dir _must_ be in the PATH. We did that above.
which -- $TARGET-as || echo $TARGET-as is not in the PATH

mkdir build-gcc
cd build-gcc
../gcc-15.1.0/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --without-headers --disable-hosted-libstdcxx
make -j$(nproc) all-gcc
make -j$(nproc) all-target-libgcc
make -j$(nproc) all-target-libstdc++-v3
make -j$(nproc) install-gcc
make -j$(nproc) install-target-libgcc
make -j$(nproc) install-target-libstdc++-v3
```
After running the above commands GCC will build libgcc in two versions - one with red-zone enabled and one without. You can check the successful build by checking the installed libgcc.a archives:
```
find $PREFIX/lib -name 'libgcc.a'
```
If all went well you should see an additional libgcc installed in the no-red-zone multilib directory: 
```
<home_path>/opt/cross/lib/gcc/x86_64-elf/15.1.0/no-red-zone/libgcc.a
<home_path>/opt/cross/lib/gcc/x86_64-elf/15.1.0/libgcc.a
```
Assuming you're using GCC to link your kernel you're probably fine. All that's needed is to make sure -mno-red-zone is in your LDFLAGS when doing the final linker call.
```
x86_64-elf-gcc $LDFLAGS -mno-red-zone -o kernel $SOURCES
```
If you're unsure which libgcc version is going to be used you can check by passing -mno-red-zone and -print-libgcc-file-name to GCC:
```
x86_64-elf-gcc -mno-red-zone -print-libgcc-file-name lib/gcc/x86_64-elf/15.1.0/no-red-zone/libgcc.a
```

### Optional
You can add this to your shell profile config file if it's not already added:
```
export PATH="$HOME/opt/cross/bin:$PATH"
```
