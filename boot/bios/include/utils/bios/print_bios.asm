[bits 16]

; Prints a string in BIOS in 16 Real Mode. Assumes BX contains the address of the string.   
print_string: 
    push bp     ; Some BIOS implementations have a bug that causes register
                ; BP to be destroyed.   It is advisable to save BP before a call to
                ; Video BIOS routines on these systems.
    push bx
    push ax 

    ; Reinitialize DS (data segment register) because it might get corrupted 
    ; by BIOS
    mov ax, 0
    mov ds, ax

    mov ah, 0x0e

loop_string:
    cmp byte [bx], 0
    je end_string
    mov al, [bx]
    int 0x10
    add bx, 1
    jmp loop_string

end_string:
    pop ax
    pop bx
    pop bp

    ret ; print_string returns

; Prints 16 bit hex values as a string in BIOS. Assumes ax contains the hex number value
print_hex_16: 
    push si 
    push ax
    push bx
    
    mov si, HEX_DIGIT_STRING + 2

loop_hex_digit_string: 
    ; get the next digit
    rol ax, 4
    mov bl, al
    and bl, 0x0F ; get the lower 4 bits

    ; convert to ASCII
    cmp bl, 9
    jbe convert_to_digit
    add bl, "A" - 10 ; convert to a letter
    jmp check_end_of_hex_digit
convert_to_digit:
    add bl, "0"

check_end_of_hex_digit:
    mov [si], bl
    add si, 1

    cmp byte [si], 0 
    jne loop_hex_digit_string

    mov bx, HEX_DIGIT_STRING
    call print_string

    pop bx
    pop ax
    pop si
    ret ; print_hex_16 returns

HEX_DIGIT_STRING:
    db "0x0000", 0  

print_new_line: ; takes no parameters
    push bx

    mov bx, NEW_LINE
    call print_string

    pop bx
    ret

print_dx_before_disk_load:  ; takes no params
    push ax
    push bx

    mov bx, DX_VALUE_BEFORE_DISK_LOAD
    call print_string
    mov ax, dx
    call print_hex_16
    call print_new_line

    pop bx
    pop ax

    ret

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
NEW_LINE db 13, 10, 0
DX_VALUE_BEFORE_DISK_LOAD       db "Value of DX before disk load: ", 0
DISK_LOAD_STATUS_MESSAGE        db "Disk load status: ", 0
