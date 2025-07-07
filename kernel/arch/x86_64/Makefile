############################################################################################
#################################### CONSTANTS/VARIABLES ###################################
############################################################################################
CC = x86_64-elf-gcc 
CFLAGS = -ffreestanding -nostdlib -mno-red-zone
LD = x86_64-elf-ld
AS = x86_64-elf-as

# Directories
KERNEL_DIR = kernel
KERNEL_BOOT_DIR = $(KERNEL_DIR)/boot
BOOT_DIR = boot
LONG_MODE_INIT_DIR = $(BOOT_DIR)/long_mode_init
BOOT_64_BIT_DIR = $(BOOT_DIR)/64_bit

############################################################################################
####################################### SOURCE FILES #######################################
############################################################################################
# Kernel source files
KERNEL_C_SOURCES = $(shell find $(KERNEL_DIR) -name "*.c")
KERNEL_C_HEADERS = $(shell find $(KERNEL_DIR) -name "*.h")

# Boot source files
BOOT_64_BIT_SOURCES = $(shell find $(BOOT_64_BIT_DIR) -name "*.s") 
LONG_MODE_INIT_SOURCES = $(shell find $(LONG_MODE_INIT_DIR) -name "*.s") 
BOOT_SOURCE = $(BOOT_DIR)/boot.s

############################################################################################
####################################### OBJECT FILES #######################################
############################################################################################
# Kernel object files 
KERNEL_OBJ = $(patsubst $(KERNEL_DIR)/%.c, $(KERNEL_DIR)/%.o, $(KERNEL_C_SOURCES))

# Boot object files
BOOT_64_BIT_OBJ = $(patsubst $(BOOT_64_BIT_DIR)/%.s, $(BOOT_64_BIT_DIR)/%.o, $(BOOT_64_BIT_SOURCES))
LONG_MODE_INIT_OBJ = $(patsubst $(LONG_MODE_INIT_DIR)/%.s, $(LONG_MODE_INIT_DIR)/%.o, $(LONG_MODE_INIT_SOURCES))
BOOT_OBJ = $(BOOT_DIR)/boot.o

############################################################################################
####################################### BINARY FILES #######################################
############################################################################################
KERNEL_BIN = x86_64-kernel.bin
LONG_MODE_INIT_BIN = $($(LONG_MODE_INIT_DIR)/%.bin)

# ISO
ISO_DIR=iso
ISO=x86_64-nurbo-os.iso

############################################################################################
############################################################################################

.PHONY: run build clean

build-iso: $(KERNEL_BIN) 
	sh ./build_iso.sh # creates the $(ISO) file

run: build-iso
	qemu-system-x86_64 -cdrom $(ISO)

clean:
	rm -fr $(KERNEL_OBJ) $(BOOT_OBJ) $(BOOT_64_BIT_OBJ) $(LONG_MODE_INIT_OBJ) $(KERNEL_BIN) \
		$(LONG_MODE_INIT_BIN) $(ISO_DIR) $(ISO) 

# Compile to binaries
$(KERNEL_BIN): $(BOOT_OBJ) $(LONG_MODE_INIT_OBJ) $(BOOT_64_BIT_OBJ) $(KERNEL_OBJ) 
	$(CC) $(CFLAGS) -T linker.ld $^ -o $@

# $(KERNEL_BIN): $(BOOT_BIN) $(LONG_MODE_INIT_BIN) $(KERNEL_64_BIT_PART_BIN)
# 	cat $(BOOT_BIN) $(LONG_MODE_INIT_BIN) $(KERNEL_64_BIT_PART_BIN) > $@
#
# $(KERNEL_64_BIT_PART_BIN): $(GDT64_OBJ) $(64_BIT_START_OBJ) $(KERNEL_OBJ)
# 	$(LD) -m elf_x86_64 -T linker.ld $^ -o $@

# $(BOOT_BIN): $(BOOT_DIR)/boot.o
# 	$(CC) $(CFLAGS) -c $^ -o $@ 
# 	# x86_64-elf-objcopy -O binary -j .text -j .data -j .rodata -j .multiboot -j .bss $^ $@


# Convert long mode init object files into flat binary files
# $(LONG_MODE_INIT_DIR)/%.bin: $(LONG_MODE_INIT_DIR)/%.o
# 	x86_64-elf-objcopy -O binary -j .text -j .data -j .rodata -j .multiboot -j .bss $^ $@

# Compile to object files
$(KERNEL_DIR)/%.o: $(KERNEL_DIR)/%.c $(KERNEL_DIR)/%.h
	$(CC) $(CFLAGS) -c $^ -o $@ 

$(BOOT_64_BIT_DIR)/%.o: $(BOOT_64_BIT_DIR)/%.s
	$(AS) --64 $^ -o $@

$(LONG_MODE_INIT_DIR)/%.o: $(LONG_MODE_INIT_DIR)/%.s
	$(AS) --64 $^ -o $@

$(BOOT_DIR)/boot.o: $(BOOT_DIR)/boot.s
	$(AS) --64 $^ -o $@
