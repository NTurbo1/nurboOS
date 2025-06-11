[bits 16]

load_2nd_stage: ; Takes no params
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
    mov ax, SECOND_STAGE_BOOT_SECTORS_COUNT     ; Total number of sectors to read                           
    mov di, 1                                   ; Starts reading from the 2nd sector, which is after the boot sector
    mov bx, SECOND_SECTOR_START                 ; Offset value 
    mov cx, 0                                   ; Segment address
                                                ; The address that the data is loaded is calculated as such:
                                                ; segment_address (cx) * 16 (0x10) + offset (0)
    call disk_load_lba

.return:
    popa
    ret
