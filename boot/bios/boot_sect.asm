[bits 16]
[org 0x7c00]

    xor ax, ax
    mov ds, ax ; Set DS to 0 
    mov es, ax ; Set ES to 0

    mov [BOOT_DRIVE], dl    ; BIOS stores our boot drive in DL, so it's best to
                            ; remember this for later.

    mov ax, 0x07e0
    cli                     ; Disable maskable interrupts
    mov ss, ax              ; Set SS to 0x07e0
    mov sp, 0x1200          ; Set SP to 0x1200. So, the stack is allocated from 
                            ; 0x07e0 * 0x10 (16 in decimal) = 0x7e00 to 
                            ; 0x7e0 * 0x10 (16 in decimal) + 0x1200 = 0x9000
    sti                     ; Enable maskable interrupts 

    mov bx, REAL_MODE_MSG
    call print_string

    mov bx, 0xa000          
    mov dh, 5
    mov dl, [BOOT_DRIVE]
    call disk_load          ; Load 5 sectors to 0x0000(ES):0x9000(BX) from
                            ; the boot disk

    mov ax, [0xa000]        ; Print out the first loaded word , which
    call print_hex_16       ; we expect to be 0xdada , stored
                            ; at address 0x9000

    mov ax, [0xa000 + 512]    ; Also , print the first word from the
    call print_hex_16         ; 2nd loaded sector : should be 0xface

    jmp $

%include "./boot/bios/include/print.asm"        ; relative to the project root
%include "./boot/bios/include/disk_load.asm"    ; relative to the project root

; Global variables
BOOT_DRIVE: db 0
REAL_MODE_MSG db "Started in 16-bit Real Mode", 13, 10, 0 

; Bootsector padding
times 510 - ($ - $$) db 0
dw 0xaa55

; We know that BIOS will load only the first 512 - byte sector from the disk,
; so if we purposely add a few more sectors to our code by repeating some
; familiar numbers , we can prove to ourselves that we actually loaded those
; additional two sectors from the disk we booted from.
times 256 dw 0xdada
times 256 dw 0xface
