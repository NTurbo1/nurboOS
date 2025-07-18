# C cross-compiler. Check the docs about how to build a cross compiler.
KERNEL_X86_DIR = kernel/arch/x86

run-nurbo-i386:
	cd $(KERNEL_X86_DIR) && \
	HOST=i386-elf ./qemu_x86.sh

clean-i386:
	cd $(KERNEL_X86_DIR) && \
	HOST=i386-elf ./clean.sh
