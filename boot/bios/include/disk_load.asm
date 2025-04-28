; Load DH sectors to ES:BX from drive DL
disk_load:
    push ax
    push bx
    push cx
    push dx ; Store DX on stack so later we can recall
            ; how many sectors were requested to be read,
            ; even if it's altered in the meantime

    mov [SECTORS_LEFT], dh  ; Set the inital number of sectors should be read.

    mov ch, 0x00    ; Select cylinder 0
    mov dh, 0x00    ; Select head 0
    mov cl, 0x02    ; Start reading from 2nd sector (i.e.
                    ; after the boot sector)

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
  
; Global variables
SECTORS_LEFT db 0
DISK_ERROR_MESSAGE db "Disk read error!", 13, 10, 0
DISK_LOAD_STATUS_MESSAGE db "Disk load status: ", 0

; Debugging messages
RETRYING_DISK_LOADING db "Retrying disk loading ...", 13, 10, 0
DONE_DISK_LOADING_RETURNING db "Done disk loading, returning ...", 13, 10, 0
