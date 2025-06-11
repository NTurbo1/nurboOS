[bits 16]
BOOT_SECTOR_START_ADDRESS   equ 0x7c00
[org BOOT_SECTOR_START_ADDRESS]
    
    xor ax, ax
    mov es, ax
    mov ds, ax

    mov [BOOT_DRIVE], dl    ; BIOS assigns the disk drive number to DL during boot. So, it's stored 
                            ; as a constant for later use.

    ; Set up the stack
    mov ax, 0x7000
    cli                     ; Disable maskable interrupts
    mov ss, ax              ; Set SS to 0x7000
    mov sp, 0x0000          ; Set SP to 0x0000. So, the stack grows downwords from 
                            ; 0x7000 * 0x10 (16 in decimal) = 0x70000 
    mov bp, sp
    sti                     ; Enable maskable interrupts     mov bp, sp

    ; Debugging message
    mov bx, REAL_MODE_MSG
    call print_string

    call load_2nd_stage

    call load_kernel

    jmp $   ; TODO: Remove after testing the load_kernel call 

    call switch_to_pm   ; It switches to long mode right after switching to protected mode successfully and should 
                        ; eventually call the kernel.

    jmp $

    %include "./boot/bios/include/second_stage/load_2nd_stage_lba.asm"
    %include "./boot/bios/include/utils/bios/disk_load_lba.asm"
    %include "./boot/bios/include/utils/bios/print_bios.asm"        

; ********************************* BOOT SECTOR DEBUGGING MESSAGES **************************************
LOADING_2ND_STAGE_BOOT_LOADER_CODE              db "Loading 2nd stage boot loader code...", 13, 10, 0
REAL_MODE_MSG                                   db "16-bit Real Mode", 13, 10, 0 

; ************************************** BOOT SECTOR VARIABLES ******************************************
BOOT_DRIVE          db 0

; Bootsector padding
times 510 - ($ - $$) db 0
dw 0xaa55

; *******************************************************************************************************
; ***********************  END OF THE BOOT SECTOR (1st 512 bytes of the disk)  **************************
; *******************************************************************************************************

SECOND_SECTOR_START:    ; Used for address and padding calculations later.

%include "./boot/bios/include/kernel/load_kernel_lba.asm"
%include "./boot/bios/include/protected_mode/GDT32.asm"
%include "./boot/bios/include/utils/print_pm.asm"

[bits 32]

; This is where we arrive after switching to and initializing protected mode.
BEGIN_PM:
    call print_protected_mode_msg
    call switch_to_lm

    jmp $

; ====================================== 2ND SECTOR PADDING =====================================
times 512 - ($ - SECOND_SECTOR_START) db 0

; *****************************************************************************************
; *****************  END OF THE 2nd SECTOR (2nd 512 bytes of the disk)  ******************
; *****************************************************************************************

THIRD_SECTOR_START:    ; Used for address and padding calculations later.

%include "./boot/bios/include/utils/bios/print_bios_messages.asm"
%include "./boot/bios/include/utils/print_pm_messages.asm"
%include "./boot/bios/include/protected_mode/switch_to_pm.asm"
%include "./boot/bios/include/long_mode/check_long_mode.asm"
%include "./boot/bios/include/long_mode/A20/check_A20.asm"
%include "./boot/bios/include/long_mode/paging/setup_paging.asm"
%include "./boot/bios/include/long_mode/enter_long_mode/GDT64.asm"
%include "./boot/bios/include/long_mode/enter_long_mode/enter_long_mode.asm"

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
    call print_cpu_not_available
    jmp $                                   ; TODO: Should stay in Protected Mode and continue with 32-bit kernel
                                            ; if the OS supports 32-bit.

%include "./boot/bios/include/constants/global_constants.asm"
%include "./boot/bios/include/constants/messages.asm"

; ================================ THE LAST BOOT LOADER SECTOR PADDING ==================================
times (SECOND_STAGE_BOOT_SECTORS_COUNT - 1) * SECTOR_BYTES_COUNT - ($ - THIRD_SECTOR_START) db 0
