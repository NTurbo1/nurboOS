############################################################################################
#################################### CONSTANTS/VARIABLES ###################################
############################################################################################
CC = i386-elf-gcc 
CFLAGS = -ffreestanding -nostdlib -lgcc
LD = i386-elf-ld
AS = i386-elf-as

# Directories
KERNEL_DIR = kernel
KERNEL_BOOT_DIR = $(KERNEL_DIR)/boot
BOOT_DIR = boot

############################################################################################
####################################### SOURCE FILES #######################################
############################################################################################
# Kernel source files
KERNEL_C_SOURCES = $(shell find $(KERNEL_DIR) -name "*.c")
KERNEL_C_HEADERS = $(shell find $(KERNEL_DIR) -name "*.h")

# Boot source files
BOOT_SOURCE = $(BOOT_DIR)/boot.s

############################################################################################
####################################### OBJECT FILES #######################################
############################################################################################
# Kernel object files 
KERNEL_OBJ = $(patsubst $(KERNEL_DIR)/%.c, $(KERNEL_DIR)/%.o, $(KERNEL_C_SOURCES))

# Boot object files
BOOT_OBJ = $(BOOT_DIR)/boot.o

############################################################################################
####################################### BINARY FILES #######################################
############################################################################################
KERNEL_BIN = x86_32-kernel.bin

# ISO
ISO_DIR=iso
ISO=x86_32-nurbo-os.iso

############################################################################################
############################################################################################

.PHONY: run build clean

build-iso: $(KERNEL_BIN) 
	sh ./build_x86_32_iso.sh # creates the $(ISO) file

run: build-iso
	qemu-system-i386 -cdrom $(ISO)

clean:
	rm -fr $(KERNEL_OBJ) $(BOOT_OBJ) $(KERNEL_BIN) $(ISO_DIR) $(ISO) 

# Compile to binaries
$(KERNEL_BIN): $(BOOT_OBJ) $(KERNEL_OBJ) 
	$(CC) $(CFLAGS) -T linker.ld $^ -o $@
	
# Compile to object files
$(KERNEL_DIR)/%.o: $(KERNEL_DIR)/%.c $(KERNEL_DIR)/%.h
	$(CC) $(CFLAGS) -c $^ -o $@ 

$(BOOT_DIR)/boot.o: $(BOOT_DIR)/boot.s
	$(AS) $^ -o $@
