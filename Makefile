# C cross-compiler
CC = gcc -m64 -ffreestanding -nostdlib

# Directories
KERNEL_DIR = kernel
DRIVERS_DIR = drivers
BOOT_DIR = boot

# BIOS
BIOS_DIR = $(BOOT_DIR)/bios
BIOS_BOOT_LOADER_BIN = $(BIOS_DIR)/boot_loader.bin
BIOS_BOOT_LOADER_ASM = $(BIOS_DIR)/boot_loader.asm
BIOS_BOOT_INCLUDE = $($(BIOS_DIR)/include/%.asm)

# Kernel
KERNEL_C_SOURCES = $(shell find $(KERNEL_DIR) -name "*.c")
KERNEL_HEADERS = $(shell find $(KERNEL_DIR) -name "*.h")
KERNEL_OBJ = $(patsubst $(KERNEL_DIR)/%.c, $(KERNEL_DIR)/%.o, $(KERNEL_C_SOURCES))
KERNEL_ENTRY_OBJ = $(KERNEL_DIR)/kernel_entry.o
KERNEL_ENTRY_ASM = $(KERNEL_DIR)/kernel_entry.asm
KERNEL_BIN = $(KERNEL_DIR)/kernel.bin

# Drivers
DRIVERS_C_SOURCES = $(shell find $(DRIVERS_DIR) -name "*.c")
DRIVERS_HEADERS = $(shell find $(DRIVERS_DIR) -name "*.h")
DRIVERS_OBJ = $(patsubst $(DRIVERS_DIR)/%.c, $(DRIVERS_DIR)/%.o, $(DRIVERS_C_SOURCES))

HEADERS = $(KERNEL_HEADERS) $(DRIVERS_HEADERS)

TARGET=os_image

.PHONY: run build clean

build: $(TARGET)

run: build
	qemu-system-x86_64 -drive if=floppy,format=raw,file=./$(TARGET)

# Creates the os_image
$(TARGET): $(BIOS_BOOT_LOADER_BIN) $(KERNEL_BIN)
	cat $^ > $(TARGET)

$(KERNEL_BIN): $(KERNEL_ENTRY_OBJ) $(KERNEL_OBJ) $(DRIVERS_OBJ)
	ld -m elf_x86_64 -e main -o $@ -Ttext 0x1000 $^ --oformat binary

%.o : %.c $(HEADERS)
	$(CC) -c $< -o $@ 

$(BIOS_BOOT_LOADER_BIN): $(BIOS_BOOT_LOADER_ASM) $(BIOS_BOOT_INCLUDE) 
	nasm $< -f bin -o $@

$(KERNEL_ENTRY_OBJ): $(KERNEL_ENTRY_ASM) 
	nasm $< -f elf64 -o $@

clean:
	rm -fr $(KERNEL_OBJ) $(KERNEL_ENTRY_OBJ) $(KERNEL_BIN) \
		$(BIOS_BOOT_LOADER_BIN) $(DRIVERS_OBJ) $(TARGET)
