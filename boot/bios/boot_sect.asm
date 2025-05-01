[bits 16]
[org 0x7c00]

    mov bp, 0x9000      ; Set the stack
    mov sp, bp

    mov bx, REAL_MODE_MSG
    call print_string

    call switch_to_pm   ; We never return from here
    
    jmp $

%include "./boot/bios/include/print.asm"        ; relative to the project root
%include "./boot/bios/include/print_pm.asm"
%include "./boot/bios/include/gdt.asm"
%include "./boot/bios/include/switch_to_pm.asm"

[bits 32]

; This is where we arrive after switching to and initializing protected mode.
BEGIN_PM:
    mov ebx, PROTECTED_MODE_MSG
    call print_string_pm

    jmp $

; Global variables
REAL_MODE_MSG db "Started in 16-bit Real Mode", 13, 10, 0 
PROTECTED_MODE_MSG db "Switched to 32-bit Proected Mode!", 13, 10, 0

; Bootsector padding
times 510 - ($ - $$) db 0
dw 0xaa55
