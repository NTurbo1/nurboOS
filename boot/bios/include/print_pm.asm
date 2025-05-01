[bits 32]

; Define constants
VIDEO_MEMORY equ 0xb8000
WHITE_ON_BLACK equ 0x0f

; Prints a null-terminated string pointed to by EBX
print_string_pm:
    push edx
    push eax

    mov edx, VIDEO_MEMORY

print_string_pm_loop:
    mov al, [ebx]
    mov ah, WHITE_ON_BLACK

    cmp al, 0 
    je print_string_pm_done

    mov [edx], ax   ; Store the character and its attributes 
                    ; at current character cell.
    
    add ebx, 1      ; Move to the next character of the string.
    add edx, 2      ; Move to the next character cell in video memory.

    jmp print_string_pm_loop

print_string_pm_done:
    pop eax
    pop edx

    ret

; Debugging messages
INSIDE_PRINT_STRING_PM db "Printing in protected mode...", 13, 10, 0
