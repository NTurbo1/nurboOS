[bits 16]
[org 0x7c00]
    
    xor ax, ax
    mov es, ax
    mov ds, ax

    mov [BOOT_DRIVE], dl

    ; Set up the stack
    mov ax, 0x07e0
    cli                     ; Disable maskable interrupts
    mov ss, ax              ; Set SS to 0x07e0
    mov sp, 0x1200          ; Set SP to 0x1200. So, the stack is allocated from 
                            ; 0x07e0 * 0x10 (16 in decimal) = 0x7e00 to 
                            ; 0x7e0 * 0x10 (16 in decimal) + 0x1200 = 0x9000
    mov bp, sp
    sti                     ; Enable maskable interrupts     mov bp, sp

    mov bx, REAL_MODE_MSG
    call print_string

    ; Loads code necessary for switching Protected Mode (GDT, print in PM, etc.)
    call load_pm_code

    ; call load_kernel    

    call switch_to_pm   ; It switches to long mode right after switching to protected mode successfully.
    
    jmp $

%include "./boot/bios/include/16_bit_real_mode/print.asm"        
%include "./boot/bios/include/16_bit_real_mode/disk_load.asm"

load_pm_code:
    push bx
    push cx
    push dx

    mov bx, LOADING_PM_CODE_MSG
    call print_string

    mov bx, SECOND_SECTOR_START
    mov dh, 5                           ; 5 sectors loaded assuming all the bootloader code fits 5 sectors.  
                                        ; The sectors are not tracked after the 2nd sector.
                                        ; Update the number of sectors loaded if you think the bootloader
                                        ; code exceeds it.
    mov dl, [BOOT_DRIVE]

    mov ch, 0x00    ; Select cylinder 0
    mov cl, 0x02    ; Start reading from 2nd sector (i.e.
                    ; after the boot sector)
    call disk_load

    pop dx
    pop cx
    pop bx

    ret     ; returns from load_pm_code.

load_kernel:
    push bx
    push cx
    push dx

    mov bx, LOADING_KERNEL_MSG
    call print_string
    
    ; Set up parameters for our disk_load routine, so
    ; that we load the first 15 sectors (excluding
    ; the boot sector) from the boot disk (i.e. our
    ; kernel code) to address KERNEL_OFFSET.
    mov bx, KERNEL_OFFSET
    mov dh, 20
    mov dl, [BOOT_DRIVE]

    mov ch, 0x00    ; Select cylinder 0
    mov cl, 0x03    ; Start reading from 3rd sector (i.e. after the sector 
                    ; that stores code for Protected Mode.)
    call disk_load

    pop dx
    pop cx
    pop bx

    ret ; returning from load_kernel

; Global constants
KERNEL_OFFSET equ 0x1000        ; TODO: Should be changed and kernel should be written from scratch in 64 bit mode!

; Global variables
BOOT_DRIVE              db 0

; ===================================================== DEBUGGING MESSAGES =======================================================
REAL_MODE_MSG           db "Started in 16-bit Real Mode", 13, 10, 0 
LOADING_KERNEL_MSG      db "Loading kernel into memory...", 13, 10, 0
LOADING_PM_CODE_MSG     db "Loading Protected Mode Code...", 13, 10, 0

; Bootsector padding
times 510 - ($ - $$) db 0
dw 0xaa55

; *****************************************************************************************
; *****************  END OF THE BOOT SECTOR (1st 512 bytes of the disk)  ******************
; *****************************************************************************************

SECOND_SECTOR_START:    ; Used for address and padding calculations later.

%include "./boot/bios/include/16_bit_real_mode/gdt.asm"
%include "./boot/bios/include/16_bit_real_mode/switch_to_pm.asm"
%include "./boot/bios/include/32_bit_protected_mode/print_pm.asm"

[bits 32]

; This is where we arrive after switching to and initializing protected mode.
BEGIN_PM:
    mov ebx, PROTECTED_MODE_MSG
    call print_string_pm

    ; call KERNEL_OFFSET

    call switch_to_lm

    jmp $

; ===================================================== DEBUGGING MESSAGES =======================================================
PROTECTED_MODE_MSG      db "Switched to 32-bit Proected Mode!", 0

; ===================================================== 2ND SECTOR PADDING =======================================================
times 512 - ($ - SECOND_SECTOR_START) db 0

; *****************************************************************************************
; *****************  END OF THE 2nd SECTOR (2nd 512 bytes of the disk)  ******************
; *****************************************************************************************

%include "./boot/bios/include/32_bit_protected_mode/check_long_mode.asm"
%include "./boot/bios/include/32_bit_protected_mode/A20/check_A20.asm"
%include "./boot/bios/include/32_bit_protected_mode/paging/setup_paging.asm"
%include "./boot/bios/include/32_bit_protected_mode/enter_long_mode/GDT64.asm"
%include "./boot/bios/include/32_bit_protected_mode/enter_long_mode/enter_long_mode.asm"

switch_to_lm:
    call check_cpuid
    cmp eax, 0
    je no_cpuid
    call check_long_mode_supported
    jmp is_A20_on                           ; Jumps to after_A20_is_set if A20 is set eventually. Otherwise, it hangs 
                                            ; forever.
after_A20_is_set:
    call setup_paging                       ; Sets up page tables addresses, identity maps the first 2 megabytes, and
                                            ; enables PML5 (5 Level Paging) if supported, doesn't otherwise.

    jmp switch_to_lm_from_pm                ; Sets the LM-bit, enables paging, loads the GDT for Long Mode, and enters
                                            ; the 64-bit mode.

    jmp $                                   

no_cpuid:
    mov ebx, CPUID_NOT_AVAILABLE
    call print_string_pm
    jmp $                                   ; TODO: Should stay in Protected Mode and continue with 32-bit kernel
                                            ; if the OS supports 32-bit.

; ===================================================== DEBUGGING MESSAGES =======================================================
CPUID_NOT_AVAILABLE db "CPUID is not available :(", 0
