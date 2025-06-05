GDT64:
    .null: equ $ - GDT64
        dq 0
    ; Notice that we set a 4gb limit for code. This is needed because the processor 
    ; will make a last limit check before the jump, and having a limit of 0 will cause 
    ; a #GP (general-protection exception). After that, the limit will be ignored. 
    .code: equ $ - GDT64
        dd 0xFFFF                                   ; Limit & Base (low, bits 0-15)
        db 0                                        ; Base (mid, bits 16-23)
        db PRESENT | NOT_SYS | EXEC | RW            ; Access
        db GRAN_4K | LONG_MODE | 0xF                ; Flags & Limit (high, bits 16-19)
        db 0                                        ; Base (high, bits 24-31)
    .data: equ $ - GDT64
        dd 0xFFFF                                   ; Limit & Base (low, bits 0-15)
        db 0                                        ; Base (mid, bits 16-23)
        db PRESENT | NOT_SYS | RW                   ; Access
        db GRAN_4K | SZ_32 | 0xF                    ; Flags & Limit (high, bits 16-19)
        db 0                                        ; Base (high, bits 24-31)
    .TSS: equ $ - GDT64
        dd 0x00000068
        dd 0x00CF8900
    .pointer:
        dw $ - GDT64 - 1
        dq GDT64

; *******************************************************************************************
; ************************************ LOCAL CONSTANTS **************************************
; *******************************************************************************************

; *************************************** ACCESS BITS ***************************************
PRESENT        equ 1 << 7
NOT_SYS        equ 1 << 4
EXEC           equ 1 << 3
DC             equ 1 << 2
RW             equ 1 << 1
ACCESSED       equ 1 << 0

; ************************************** FLAGS BITS *****************************************
GRAN_4K       equ 1 << 7
SZ_32         equ 1 << 6
LONG_MODE     equ 1 << 5
