# C cross-compiler. Check the docs about how to build a cross compiler.
X86_64_DIR = kernel/arch/x86_64
X86_32_DIR = kernel/arch/x86_32

run-x86_64-os:
	$(MAKE) -C $(X86_64_DIR) run

clean-x86_64:
	$(MAKE) -C $(X86_64_DIR) clean 

run-x86_32-os:
	$(MAKE) -C $(X86_32_DIR) run

clean-x86_32:
	$(MAKE) -C $(X86_32_DIR) clean
