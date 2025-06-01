[bits 16]

; Loads the kernel code using the extended BIOS disk loading with LBA. 

; Loads data from a disk using extended BIOS disk read functionality 
; that uses LBA for storage memory location.
; Params:
;   - ax <- # of sectors to read
;   - bx <- offset value
;   - cx <- segment address
;   - di <- starting sector (LBA)
disk_load_lba:
    pusha

.update_dap:
    mov [.dap + 16], ax
    mov [.dap + 32], bx
    mov [.dap + 48], cx
    mov [.dap + 64], di

    ; Nullify the param registers before they're used after.
    xor ax, ax
    xor bx, bx
    xor cx, cx
    xor di, di

.load:
    mov si, .dap
    mov ah, 0x42
    ; dl (disk is expected to be given by bootloader), so it's skipped.
    int 0x13
    jc .disk_error
    
    jmp .return

.disk_error:
    ; Reinitialize DS (data segment register) because it might get corrupted 
    ; by BIOS
    push ax
    mov ax, 0
    mov ds, ax
    pop ax

    mov bx, KERNEL_LOAD_DISK_READ_ERROR_MSG 
    call print_string

    call print_disk_load_status                 ; external routine

    jmp $

.return:
    popa
    ret

align 16
; Disk Address Packet (DAP) with default values.
.dap: 
    db 0x10             ; Size of the DAP (16 bytes)
    db 0x00             ; Reserved

    dw 0x0              ; # of sectors to read. 
    dw 0x0              ; offset value
    dw 0x0              ; segment address
                        
    dq 0                ; Starting sector.

; ==================================== DEBUGGING MESSAGES =========================================
KERNEL_LOAD_DISK_READ_ERROR_MSG db "Disk read error during kernel loading with LBA!", 13, 10, 0
