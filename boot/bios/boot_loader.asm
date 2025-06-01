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

    call load_kernel

    ; call switch_to_pm   ; It switches to long mode right after switching to protected mode successfully.
    
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
    mov dh, 4                           ; Note: 4 sectors (after the boot sector, which is the 1st sector)
                                        ; to load assuming all the bootloader code fits 5 sectors.  
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
    pusha

    mov bx, LOADING_KERNEL_MSG
    call print_string

    mov dl, [BOOT_DRIVE]

    mov ax, 127                     ; Max # of of sectors can be read at once.
    mov bx, 0x10
    mov cx, 0xffff                  ; The final address the data is read to is CX:BX = 0xffff * 16 (0x10) + 0x10 = 
                                    ; 0xffff0 + 0x10 = 0x100000 - kernel offset address.

    mov di, 5                       ; Start reading from sector 6 (sector indexing starts from 0) assuming the 
                                    ; bootloader code takes up 5 sectors.
                                    ; Note: should be updated accordingly as the bootloader size grows.
.loop:
    cmp word [KERNEL_SECTORS_LEFT], 127
    jle .loop.last_load
    call disk_load_lba       ; Halts if there is a disk loading error.
    sub [KERNEL_SECTORS_LEFT], ax
    jmp .loop
.loop.last_load:
    mov bx, LOADING_LAST_KERNEL_SECTORS_MSG
    call print_string

    mov ax, KERNEL_SECTORS_LEFT
    call disk_load_lba       ; Halts if there is a disk loading error.
    call print_disk_load_status

.return:
    mov bx, KERNEL_LOAD_SUCCESS_MSG
    call print_string

    popa
    ret ; returning from load_kernel

; Global constants
KERNEL_OFFSET equ 0x00100000    ; The kernel entry point at the 1st MiB of the physical address.
KERNEL_SECTORS_LEFT dw 4096         ; Assuming the kernel code size is no bigger than 
                                    ; 2 MiB = 4096 * 512 (sector size).
                                    ; Note: should be updated accordingly as the kernel size grows.
 
; Global variables
BOOT_DRIVE              db 0

; ================================ DEBUGGING MESSAGES =====================================
REAL_MODE_MSG                   db "Started in 16-bit Real Mode", 13, 10, 0 
LOADING_PM_CODE_MSG             db "Loading Protected Mode Code...", 13, 10, 0

; Bootsector padding
times 510 - ($ - $$) db 0
dw 0xaa55

; *****************************************************************************************
; *****************  END OF THE BOOT SECTOR (1st 512 bytes of the disk)  ******************
; *****************************************************************************************

SECOND_SECTOR_START:    ; Used for address and padding calculations later.

%include "./boot/bios/include/16_bit_real_mode/disk_load_lba.asm"
%include "./boot/bios/include/16_bit_real_mode/gdt.asm"
%include "./boot/bios/include/32_bit_protected_mode/print_pm.asm"

; ================================ Debugging Messages =====================================
LOADING_KERNEL_MSG              db "Loading kernel into memory...", 13, 10, 0
KERNEL_LOAD_SUCCESS_MSG         db "Successfully loaded the kernel!", 13, 10, 0
LOADING_LAST_KERNEL_SECTORS_MSG db "Loading the last sectors of kernel...", 13, 10, 0

[bits 32]

; This is where we arrive after switching to and initializing protected mode.
BEGIN_PM:
    mov ebx, PROTECTED_MODE_MSG
    call print_string_pm

    ; call KERNEL_OFFSET

    call switch_to_lm

    jmp $

; =================================== DEBUGGING MESSAGES ========================================
PROTECTED_MODE_MSG      db "Switched to 32-bit Proected Mode!", 0

; ====================================== 2ND SECTOR PADDING =====================================
times 512 - ($ - SECOND_SECTOR_START) db 0

; *****************************************************************************************
; *****************  END OF THE 2nd SECTOR (2nd 512 bytes of the disk)  ******************
; *****************************************************************************************

THIRD_SECTOR_START:    ; Used for address and padding calculations later.

%include "./boot/bios/include/16_bit_real_mode/switch_to_pm.asm"

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

; ===================================================== 5th SECTOR PADDING =======================================================
times 1536 - ($ - THIRD_SECTOR_START) db 0

; *****************************************************************************************
; *****************  END OF THE 5th SECTOR (5th 512 bytes of the disk)  ******************
; *****************************************************************************************
