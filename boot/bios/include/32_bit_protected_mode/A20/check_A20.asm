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
    jne A20_on                  ; if not equivalent, A20 line is set. Otherwise A20 line is cleared not set.

    mov ebx, A20_IS_NOT_SET_MSG
    call print_string_pm        ; external procedure
    jmp enable_A20

A20_on:
    mov ebx, A20_IS_SET_MSG
    call print_string_pm        ; external procedure

    jmp after_A20_is_set

enable_A20:
    mov ebx, ENABLING_A20_MSG
    call print_string_pm        ; external procedure

    mov ebx, GIVE_UP_ENABLING_A20_MSG
    call print_string_pm        ; external procedure

    jmp $                       ; TODO: Implement enabling the A20 line. If A20 is successfully enabled,
                                ; then jump to after_A20_is_set.

; ===================================================== DEBUGGING MESSAGES =======================================================
A20_IS_NOT_SET_MSG db "A20 is not set.", 0
A20_IS_SET_MSG db "A20 is set!", 0
ENABLING_A20_MSG db "Enabling the A20 lint...", 0
GIVE_UP_ENABLING_A20_MSG db "Couldn't enable the A20 line... Give up :(", 0
