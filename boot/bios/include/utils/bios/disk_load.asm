; Load DH sectors to ES:BX from drive DL
disk_load:
    push ax
    push bx
    push cx
    push dx ; Store DX on stack so later we can recall
            ; how many sectors were requested to be read,
            ; even if it's altered in the meantime
    push di

    mov [SECTORS_LEFT], dh  ; Set the inital number of sectors should be read.

    mov dh, 0x00    ; Select head 0

next_group:
    mov di, 5

load_again:
    mov ah, 0x02                    ; BIOS read sector function
    mov al, [SECTORS_LEFT]          ; Read remaining sectors
    int 0x13                        ; BIOS Disk I/O interrupt
    call print_disk_load_status
    jc retry_loading
    sub [SECTORS_LEFT], al          ; Calculate the remaining sectors to be read 
    jz done_loading 
    mov cl, 0x01                    ; Always sector 1 
    xor dh, 1                       ; Next head on diskette! 
    jnz next_group 
    inc ch                          ; Next cylinder 
    jmp next_group 

retry_loading: 
    push bx
    mov bx, RETRYING_DISK_LOADING 
    call print_string
    pop bx

    mov ah, 0x00                    ; Reset diskdrive 
    int 0x13 
    call print_disk_load_status 
    dec di 
    jnz load_again 
    jmp disk_error 

done_loading: 
    mov bx, DONE_DISK_LOADING_RETURNING
    call print_string

    pop di
    pop dx 
    pop cx 
    pop bx 
    pop ax
    ret     ; disk_load returns

disk_error:
    mov bx, DISK_ERROR_MESSAGE
    call print_string   ; external print routine
    jmp $

print_disk_load_status: ; takes no parameters
    push bx

    mov bx, DISK_LOAD_STATUS_MESSAGE
    call print_string
    call print_hex_16   ; AX contains the status of INT 0x13
    call print_new_line

    pop bx
    ret
  
; *************************************************************************************************
; ************************************** LOCAL VARIABLES *****************************************
; ************************************************************************************************* 
SECTORS_LEFT db 0
