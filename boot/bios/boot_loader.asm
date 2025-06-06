[bits 16]
[org 0x7c00]
    
    xor ax, ax
    mov es, ax
    mov ds, ax

    mov [BOOT_DRIVE], dl    ; BIOS assigns the disk drive number to DL during boot. So, it's stored 
                            ; as a constant for later use.

    ; Set up the stack
    mov ax, 0x07e0
    cli                     ; Disable maskable interrupts
    mov ss, ax              ; Set SS to 0x07e0
    mov sp, 0x1200          ; Set SP to 0x1200. So, the stack is allocated from 
                            ; 0x07e0 * 0x10 (16 in decimal) = 0x7e00 to 
                            ; 0x7e0 * 0x10 (16 in decimal) + 0x1200 = 0x9000
    mov bp, sp
    sti                     ; Enable maskable interrupts     mov bp, sp

    ; Debugging message
    mov bx, REAL_MODE_MSG
    call print_string
    
    ; Loads the 2nd stage bootloader code into memory
    call load_2nd_stage

    jmp $   ; TODO: Remove after testing the load_2nd_stage call 

    call load_kernel

    call switch_to_pm   ; It switches to long mode right after switching to protected mode successfully.
    
    jmp $

%include "./boot/bios/include/utils/bios/print_bios.asm"        
%include "./boot/bios/include/utils/bios/disk_load_lba.asm"

load_2nd_stage:
    pusha

    ; Nullify the registers before usage
    xor ax, ax
    xor bx, bx
    xor cx, cx
    xor dx, dx

    ; Debugging message
    mov bx, LOADING_2ND_STAGE_BOOT_LOADER_CODE
    call print_string

    ; Initialize the params to disk_load_lba routine
    mov ax, SECOND_STAGE_BOOT_SECTORS_COUNT     ; Total number of sectors read                           
    mov di, 2                                   ; Starts reading from the 2nd sector, which is after the boot sector
    mov bx, SECOND_SECTOR_START                              ; Offset value 
    mov cx, 0                                   ; Segment address
                                                ; The address that the data is loaded is calculated as such:
                                                ; segment_address (cx) * 16 (0x10) + offset (0)
    mov dl, [BOOT_DRIVE]

    call disk_load_lba

.return:
    popa
    ret     ; returns from load_pm_code.

; ********************************* BOOT SECTOR DEBUGGING MESSAGES **************************************
LOADING_2ND_STAGE_BOOT_LOADER_CODE              db "Loading 2nd stage boot loader code...", 13, 10, 0
REAL_MODE_MSG                                   db "16-bit Real Mode", 13, 10, 0 

; ************************************** BOOT SECTOR VARIABLES ******************************************
BOOT_DRIVE          db 0



; Bootsector padding
times 510 - ($ - $$) db 0
dw 0xaa55

; *****************************************************************************************
; *****************  END OF THE BOOT SECTOR (1st 512 bytes of the disk)  ******************
; *****************************************************************************************

SECOND_SECTOR_START:    ; Used for address and padding calculations later.

load_kernel:
    pusha

    mov bx, LOADING_KERNEL_MSG
    call print_string

    mov dl, [BOOT_DRIVE]

    mov ax, MAX_SECTORS_NUM_CAN_BE_READ_AT_ONCE
    mov bx, 0x10
    mov cx, 0xffff                  ; The final address the data is read to is CX:BX = 0xffff * 16 (0x10) + 0x10 = 
                                    ; 0xffff0 + 0x10 = 0x100000 - kernel offset address.

    mov di, 5                       ; Start reading from sector 6 (sector indexing starts from 0) assuming the 
                                    ; bootloader code takes up 5 sectors.
                                    ; Note: should be updated accordingly as the bootloader size grows.
.loop:
    cmp word [KERNEL_SECTORS_LEFT], MAX_SECTORS_NUM_CAN_BE_READ_AT_ONCE
    jle .loop.last_load

    ; Debugging message
    mov bx, LOADING_NEXT_KERNEL_CHUNK_MSG
    call print_string

    call disk_load_lba                              ; Halts if there is a disk loading error.
    mov ax, MAX_SECTORS_NUM_CAN_BE_READ_AT_ONCE
    sub [KERNEL_SECTORS_LEFT], ax
    add di, MAX_SECTORS_NUM_CAN_BE_READ_AT_ONCE
    jmp .loop
.loop.last_load:
    mov bx, LOADING_LAST_KERNEL_SECTORS_MSG
    call print_string

    mov ax, [KERNEL_SECTORS_LEFT]
    call disk_load_lba              ; Halts if there is a disk loading error.
    call print_disk_load_status

.return:
    mov bx, KERNEL_LOAD_SUCCESS_MSG
    call print_string

    popa
    ret ; returning from load_kernel

%include "./boot/bios/include/protected_mode/GDT32.asm"
%include "./boot/bios/include/utils/print_pm.asm"

[bits 32]

; This is where we arrive after switching to and initializing protected mode.
BEGIN_PM:
    mov ebx, PROTECTED_MODE_MSG
    call print_string_pm

    call switch_to_lm

    jmp $

; ====================================== 2ND SECTOR PADDING =====================================
times 512 - ($ - SECOND_SECTOR_START) db 0

; *****************************************************************************************
; *****************  END OF THE 2nd SECTOR (2nd 512 bytes of the disk)  ******************
; *****************************************************************************************

THIRD_SECTOR_START:    ; Used for address and padding calculations later.

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
    mov ebx, CPUID_NOT_AVAILABLE
    call print_string_pm
    jmp $                                   ; TODO: Should stay in Protected Mode and continue with 32-bit kernel
                                            ; if the OS supports 32-bit.

%include "./boot/bios/include/constants/global_constants.asm"
%include "./boot/bios/include/constants/messages.asm"

; ================================ THE LAST BOOT LOADER SECTOR PADDING ==================================
times (SECOND_STAGE_BOOT_SECTORS_COUNT - 2) * SECTOR_BYTES_COUNT - ($ - THIRD_SECTOR_START) db 0

; *****************************************************************************************
; *****************  END OF THE 5th SECTOR (5th 512 bytes of the disk)  ******************
; *****************************************************************************************
