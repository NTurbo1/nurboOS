ENTRY(kernel_init)

MAXPAGESIZE = 4096;
KERNEL_BASE = 0xFFFFFFFF80000000;

OUTPUT_FORMAT(elf64-x86-64)

SECTIONS
{
  .text.start KERNEL_BASE : {
    kernel/init/kernel_entry.o( .text )
  }

  .text : ALIGN(MAXPAGESIZE) {
_TEXT_START_ = .;
    *(.text)
_TEXT_END_ = .;
  }

  .data : ALIGN(MAXPAGESIZE) {
_DATA_START_ = .;
    *(.data)
_DATA_END_ = .;
  }

  .bss : ALIGN(MAXPAGESIZE) {
_BSS_START_ = .;
    *(.bss)
_BSS_END_ = .;
  }

  .rodata : ALIGN(MAXPAGESIZE) {
_RODATA_START_ = .;
  *(.rodata .rodata.*)
_RODATA_END_ = .;
}

_KERNEL_END_ = .;
}
