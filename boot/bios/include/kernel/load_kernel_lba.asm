[bits 16]

load_kernel:
    pusha

    call print_loading_kernel_msg

    ; Nullify the registers before usage
    xor ax, ax
    xor bx, bx
    xor cx, cx
    xor dx, dx
    xor di, di

    mov ax, MAX_SECTORS_NUM_CAN_BE_READ_AT_ONCE
.loop:
    mov bx, 0x9c00 + 
    mov cx, 0                       ; The final address the data is read to is CX:BX = 0xffff * 16 (0x10) + 0x10 = 
                                    ; 0xffff0 + 0x10 = 0x100000 - kernel offset address.

    mov di, SECOND_STAGE_BOOT_SECTORS_COUNT + 1     ; Start reading from where the bootloader code ends. 
                                                    ; Note: LBA is 0 index based

    cmp word [KERNEL_SECTORS_LEFT], MAX_SECTORS_NUM_CAN_BE_READ_AT_ONCE
    jle .loop.last_load

    call print_loading_next_kernel_chunk_msg

    call disk_load_lba                              ; Halts if there is a disk loading error.
    mov ax, MAX_SECTORS_NUM_CAN_BE_READ_AT_ONCE
    sub [KERNEL_SECTORS_LEFT], ax
    add di, MAX_SECTORS_NUM_CAN_BE_READ_AT_ONCE
    jmp .loop
.loop.last_load:
    call print_loading_last_kernel_sectors_msg

    mov ax, [KERNEL_SECTORS_LEFT]
    call disk_load_lba              ; Halts if there is a disk loading error.
    call print_disk_load_status

.return:
    call print_kernel_load_success_msg
    popa
    ret

; ****************************************************************************************************************
; ********************************************* LOCAL VARIABLES **************************************************
; ****************************************************************************************************************
NEXT_KERNEL_CHUNK_OFFSET db 0
