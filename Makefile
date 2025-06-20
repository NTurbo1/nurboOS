# C cross-compiler. Check the docs about how to build a cross compiler.
CC = x86_64-elf-gcc -ffreestanding -mno-red-zone

# Directories
KERNEL_DIR = kernel
DRIVERS_DIR = drivers
KERNEL_BOOT_DIR = $(KERNEL_DIR)/boot

# Kernel
KERNEL_C_SOURCES = $(shell find $(KERNEL_DIR) -name "*.c")
KERNEL_HEADERS = $(shell find $(KERNEL_DIR) -name "*.h")
KERNEL_OBJ = $(patsubst $(KERNEL_DIR)/%.c, $(KERNEL_DIR)/%.o, $(KERNEL_C_SOURCES))
KERNEL_BIN = $(KERNEL_DIR)/kernel.bin

# Drivers
DRIVERS_C_SOURCES = $(shell find $(DRIVERS_DIR) -name "*.c")
DRIVERS_HEADERS = $(shell find $(DRIVERS_DIR) -name "*.h")
DRIVERS_OBJ = $(patsubst $(DRIVERS_DIR)/%.c, $(DRIVERS_DIR)/%.o, $(DRIVERS_C_SOURCES))

HEADERS = $(KERNEL_HEADERS) $(DRIVERS_HEADERS)

TARGET=nurbo_os.iso

.PHONY: run build clean

build: $(TARGET)

run: build
	qemu-system-x86_64 -drive format=raw,file=./$(TARGET)

# Creates the iso file
$(TARGET): $(BIOS_BOOT_LOADER_BIN) $(KERNEL_BIN)
	cat $^ > $(TARGET)

$(KERNEL_BIN): $(KERNEL_INIT_OBJ) $(KERNEL_OBJ) $(DRIVERS_OBJ)
	x86_64-elf-ld -nostdlib -T $(KERNEL_DIR)/linker.ld -o $@ $^

%.o : %.c $(HEADERS)
	$(CC) -c $< -o $@ 

$(BIOS_BOOT_LOADER_BIN): $(BIOS_BOOT_LOADER_ASM) $(BIOS_BOOT_INCLUDE) 
	nasm $< -f bin -o $@

$(KERNEL_INIT_OBJ): $(KERNEL_INIT_ASM)
	nasm $^ -f elf64 -o $@

clean:
	rm -fr $(KERNEL_OBJ) $(KERNEL_ENTRY_OBJ) $(KERNEL_BIN) \
		$(BIOS_BOOT_LOADER_BIN) $(DRIVERS_OBJ) $(TARGET)
