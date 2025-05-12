[bits 32]

; Constants
VGA_ADDRESS equ 0xb8000
WHITE_ON_BLACK equ 0x0f
VGA_WIDTH equ 80
VGA_HEIGHT equ 25
VGA_REGISTER_INDEX_PORT equ 0x3d4
VGA_REGISTER_DATA_PORT equ 0x3d5
VGA_CURSOR_LOCATION_HIGH_BYTE_REG equ 0x0e 
VGA_CURSOR_LOCATION_LOW_BYTE_REG equ 0x0f

; Prints a null-terminated string pointed to by EBX
print_string_pm:
    push eax
    push ebx

    call read_cursor_location   
    ; Now AX contains the VGA cursor location in characters (not in bytes)

    shl eax, 1          ; Multiply by 2 (each char = 2 bytes)

.loop:
    cmp byte [ebx], 0                                            ; Check for null terminator
    je .done

    mov cl, [ebx]
    mov byte [VGA_ADDRESS + eax], cl                       ; ASCII char
    mov byte [VGA_ADDRESS + eax + 1], WHITE_ON_BLACK        ; Attribute: white on black
    add eax, 2
    add ebx, 1
    jmp .loop

.done:
    shr eax, 1                                      ; Convert back to char index by dividing by 2, EAX holds the new cursor pos.
    call set_cursor_location_to_the_next_line       ; Updates the current cursor location from AX

    pop ebx
    pop eax
    ret

; Reads the current cursor location in VGA to AX
read_cursor_location:
    push edx
    push ecx                                                ; I had to use CX register to store the cursor location 
                                                            ; temporarily and then move them back to AX register.
                                                            ; Because the OUT instruction only writes from EAX 32 bits
                                                            ; (16 bits from AX and a byte from AL)

    mov dx, VGA_REGISTER_INDEX_PORT                         ; Set dx to the VGA Control Index Port address. We write 
                                                            ; indexes of the VGA internal registers to the index port
                                                            ; in order to read/write from/to internal registers.
    mov al, VGA_CURSOR_LOCATION_LOW_BYTE_REG
    out dx, al                                              ; Set the index register value to the cursor location 
                                                            ; low byte register address.

    mov dx, VGA_REGISTER_DATA_PORT                          ; Set DX to the data port where we read the low byte of
                                                            ; the cursor location from.
    in al, dx                                               ; Read the cursor location low byte to AL.
    mov cl, al                                              ; Store it to CL temporarily, will be moved back to AX later.

    ; Do a similar process to read the high byte of the cursor location.

    mov dx, VGA_REGISTER_INDEX_PORT
    mov al, VGA_CURSOR_LOCATION_HIGH_BYTE_REG
    out dx, al                                              
    mov dx, VGA_REGISTER_DATA_PORT
    in al, dx
    mov ch, al

    ; Now CX contains the VGA cursor location 

    mov ax, cx                                              ; Move the cursor location to AX, the return value

    pop ecx
    pop edx
    ret

; Expects EAX to contain the current cursor location (in characters, not in bytes).
set_cursor_location_to_the_next_line:
    push eax
    push ecx
    push edx

    mov cx, VGA_WIDTH
    xor edx, edx
    div cx                          ; AX = AX / VGA_WIDTH = the previous row, DX = remainder = the current column  
    add eax, 1                      ; EAX = previous row + 2 = next row
    imul eax, VGA_WIDTH             ; EAX = EAX (next row) * VGA_WIDTH = new cursor position (in characters)

    ; Now EAX contains the new cursor position in characters.
    call update_cursor_location     ; Update the cursor location to the next line

    pop edx
    pop ecx
    pop eax
    ret

; Updates the cursor location in VGA from EAX. Expects EAX to contain the new cursor location 
; (in characters, not in bytes).
update_cursor_location:
    push ecx
    push edx

    mov ecx, eax                    ; Move the new cursor location from EAX to ECX because the OUT instruction 
                                    ; uses only EAX, AX, and AL registers to write from 32, 16, and 8 bits 
                                    ; respectively.

    ; Update the low byte of the cursor location from AL
    mov dx, VGA_REGISTER_INDEX_PORT                     ; Set dx to the VGA Control Index Port address. We write 
                                                        ; indexes of the VGA internal registers to the index port
                                                        ; in order to read/write from/to internal registers.

    mov al, VGA_CURSOR_LOCATION_LOW_BYTE_REG            
    out dx, al                                          ; Set the index register value to the cursor location 
                                                        ; low byte register address.

    mov dx, VGA_REGISTER_DATA_PORT                      ; Set DX to the data port where we write the new low byte of
                                                        ; the cursor location to.
    mov al, cl                                          ; Restore the cursor location low byte from CL before updating.
    out dx, al                                          ; Write the new cursor location low byte from AL.

    ; Do a similar process to update high byte of the cursor location from AH
    mov dx, VGA_REGISTER_INDEX_PORT 
    mov al, VGA_CURSOR_LOCATION_HIGH_BYTE_REG
    out dx, al
    mov dx, VGA_REGISTER_DATA_PORT 
    mov al, ch                                          ; Restore the cursor location high byte from CH before updating.
    out dx, al

    pop edx
    pop ecx
    ret

; Debugging messages
INSIDE_PRINT_STRING_PM db "Printing in protected mode...", 0
