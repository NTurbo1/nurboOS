[bits 32]

; Check A20 line
; Returns to caller if A20 gate is cleared.
; Continues to A20_on if A20 line is set.
; Written by Elad Ashkcenazi 
is_A20_on:   

    pushad
    mov edi, 0x112345           ; odd megabyte address.
    mov esi, 0x012345           ; even megabyte address.
    mov [esi], esi              ; making sure that both addresses contain diffrent values.
    mov [edi], edi              ; (if A20 line is cleared the two pointers would point 
                                ; to the address 0x012345 that would contain 0x112345 (edi)) 
    cmpsd                       ; compare addresses to see if the're equivalent.
    popad
    jne A20_on                  ; if not equivalent, A20 line is set.

    mov ebx, A20_IS_NOT_SET
    call print_string_pm        ; external procedure
    ret                         ; if equivalent, the A20 line is cleared.

A20_on:
    mov ebx, A20_IS_SET
    call print_string_pm        ; external procedure

    jmp $                       ; TODO: move to the next instruction to enable Long Mode.

; ===================================================== DEBUGGING MESSAGES =======================================================
A20_IS_NOT_SET db "A20 is not set.", 0
A20_IS_SET db "A20 is set!", 0
