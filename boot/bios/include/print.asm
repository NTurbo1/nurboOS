print_string:
    pusha
    mov ah, 0x0e

    .loop_string:
        cmp byte [bx], 0
        je .end_string
        mov al, [bx]
        int 0x10
        add bx, 1
        jmp .loop_string
    .end_string:
        popa
        ret

; Prints 16 bit hex values as a string. Assumes ax contains the hex number value
print_hex_16: 
    pusha
    
    mov si, HEX_DIGIT_STRING + 2

.loop_hex_digit_string: 
    ; get the next digit
    rol ax, 4
    mov bl, al
    and bl, 0x0F ; get the lower 4 bits

    ; convert to ASCII
    cmp bl, 9
    jbe .convert_to_digit
    add bl, "A" - 10 ; convert to a letter
    jmp .check_end_of_hex_digit
.convert_to_digit:
    add bl, "0"

.check_end_of_hex_digit:
    mov [si], bl
    add si, 1

    cmp byte [si], 0 
    jne .loop_hex_digit_string

    mov bx, HEX_DIGIT_STRING
    call print_string

    call reset_hex_digit_string
    
    popa
    ret

HEX_DIGIT_STRING:
    db "0x0000", 0  

reset_hex_digit_string: ; sets HEX_DIGIT_STRING to "0x0000"
    push bx

    mov bx, HEX_DIGIT_STRING + 2 ; skip "0x"
    .reset_loop:
        cmp byte [bx], 0
        je .end_reset
        mov byte [bx], '0'
        jmp .reset_loop

    .end_reset:
        pop bx
        ret
