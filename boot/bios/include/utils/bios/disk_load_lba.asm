[bits 16]

; Loads the kernel code using the extended BIOS disk loading with LBA. 

; Loads data from a disk using extended BIOS disk read functionality 
; that uses LBA for storage memory location.
; Params:
;   - ax <- # of sectors to read
;   - bx <- offset value
;   - cx <- segment address
;   - di <- starting sector (LBA)
;   - dl <- disk drive number
disk_load_lba:
    pusha

.update_dap:
    mov word    [.dap + 2], ax      ; # of sectors to read
    mov word    [.dap + 4], bx      ; offset
    mov word    [.dap + 6], cx      ; segment
    mov word    [.dap + 8], di      ; lower 16 bits of LBA
    mov word    [.dap + 10], 0      ; next 16 bits of LBA
    mov dword   [.dap + 12], 0      ; upper 32 bits of LBA (set to 0)

    ; Nullify the param registers before they're used after.
    xor ax, ax
    xor bx, bx
    xor cx, cx
    xor di, di

.load:
    ; Debugging messages
    call print_dx_before_disk_load

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
    mov byte [DISK_LOAD_RETRY_ATTEMPTS_LEFT], DISK_LOAD_RETRY_MAX_COUNT  ; Reset the number of retries
    mov bx, LOADED_2ND_STAGE_SUCCESSFULLY
    call print_string
    popa

    ret

align 16

; Disk Address Packet (DAP) with default values.
.dap:
    db 0x10                 ; size of DAP (16)
    db 0x00                 ; reserved
    dw 0x0000               ; number of sectors to read     --> offset +2
    dw 0x0000               ; offset (within segment)       --> offset +4
    dw 0x0000               ; segment                       --> offset +6
    dq 0x0000000000000000   ; LBA                           --> offset +8

; ***************************************** LOCAL VARIABLES *******************************************
DISK_LOAD_RETRY_ATTEMPTS_LEFT   db DISK_LOAD_RETRY_MAX_COUNT
LOADED_2ND_STAGE_SUCCESSFULLY   db "Successfully loaded the 2nd stage boot loader code!", 13, 10, 0

; ***************************************** LOCAL CONSTANTS *******************************************
DISK_LOAD_RETRY_MAX_COUNT equ 5
