.code64

.global GDT64_null 
.global GDT64_code 
.global GDT64_data 
.global GDT64_TSS 
.global GDT64_pointer 

GDT64:

.set GDT64_null, . - GDT64
    .quad 0
    # Notice that we set a 4gb limit for code. This is needed because the processor 
    # will make a last limit check before the jump, and having a limit of 0 will cause 
    # a #GP (general-protection exception). After that, the limit will be ignored. 

.set GDT64_code, . - GDT64
    .long 0xFFFF                                   # Limit & Base (low, bits 0-15)
    .byte 0                                        # Base (mid, bits 16-23)
    .byte PRESENT | NOT_SYS | EXEC | RW            # Access
    .byte GRAN_4K | LONG_MODE | 0xF                # Flags & Limit (high, bits 16-19)
    .byte 0                                        # Base (high, bits 24-31)

.set GDT64_data, . - GDT64
    .long 0xFFFF                                   # Limit & Base (low, bits 0-15)
    .byte 0                                        # Base (mid, bits 16-23)
    .byte PRESENT | NOT_SYS | RW                   # Access
    .byte GRAN_4K | SZ_32 | 0xF                    # Flags & Limit (high, bits 16-19)
    .byte 0                                        # Base (high, bits 24-31)

.set GDT64_TSS, . - GDT64
    .long 0x00000068
    .long 0x00CF8900

GDT64_pointer:
    .word . - GDT64 - 1
    .quad GDT64

# *************************************** ACCESS BITS ***************************************
.set PRESENT,       1 << 7
.set NOT_SYS,       1 << 4
.set EXEC,          1 << 3
.set DC,            1 << 2
.set RW,            1 << 1
.set ACCESSED,      1 << 0

# ************************************** FLAGS BITS *****************************************
.set GRAN_4K,       1 << 7
.set SZ_32,         1 << 6
.set LONG_MODE,     1 << 5
