[org 0x7c00]

    mov bx, HELLO_MSG
    call print_string

    mov bx, GOODBYE_MSG
    call print_string

    mov ax, 0x1FBA
    call print_hex_16

    jmp $

%include "./boot/bios/include/print.asm" ; relative to the project root

HELLO_MSG:
    db "Hello, World!", 13, 10, 0
GOODBYE_MSG:
    db "Goodbye!", 13, 10, 0

    times 510 - ($ - $$) db 0
    dw 0xaa55
