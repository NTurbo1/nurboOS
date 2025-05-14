; Set the long mode bit in the EFER MSR and then enable paging and then 
; we are in compatibility mode (which is part of long mode)
switch_to_lm_from_pm:
    ; Set the LM-bit.
    mov ecx, 0xC0000080             ; Set the C-register to 0xC0000080, which is the EFER MSR (Model Specific Register).
    rdmsr                           ; Read from the model specific register.
    or eax, 1 << 8                  ; Set the LM-bit which is the 9th bit (bit 8).
    wrmsr                           ; Write to the model specific register.

    mov ebx, SET_LM_BIT_MSG
    call print_string_pm            ; External procedure.
    xor ebx, ebx                    ; Set EBX to 0 in order to not get nasty bugs later.

    ; Enable paging.
    mov eax, cr0                    ; Set the A-register to control register 0.
    or eax, 1 << 31                 ; Set the PG-bit, which is the 32nd bit (bit 31).
    mov cr0, eax                    ; Set control register 0 to the A-register.

    mov ebx, PAGING_ENABLED_MSG
    call print_string_pm            ; External procedure.
    xor ebx, ebx                    ; Set EBX to 0 in order to not get nasty bugs later.

    ; Now we're in compatibility mode.

    ; Load GDT for Long Mode and jump to 64-bit.  
    lgdt [GDT64.pointer]         ; Load the 64-bit global descriptor table.
    jmp GDT64.code:realm64       ; Set the code segment and enter 64-bit long mode.

[bits 64]

realm64:
    cli                           ; Clear the interrupt flag.
    mov ax, GDT64.data            ; Set the A-register to the data descriptor.
    mov ds, ax                    ; Set the data segment to the A-register.
    mov es, ax                    ; Set the extra segment to the A-register.
    mov fs, ax                    ; Set the F-segment to the A-register.
    mov gs, ax                    ; Set the G-segment to the A-register.
    mov ss, ax                    ; Set the stack segment to the A-register.
    mov edi, 0xB8000              ; Set the destination index to 0xB8000 (the VGA (Video Graphics Array) address).
    mov rax, 0x1F201F201F201F20   ; Set the A-register to 0x1F201F201F201F20.
    mov ecx, 500                  ; Set the C-register to 500.
    rep stosq                     ; Clear the screen.
    hlt                           ; Halt the processor.

; ======================================== DEBUGGING MESSAGES ============================================
SET_LM_BIT_MSG db "Set LM-bit.", 0
PAGING_ENABLED_MSG db "Paging is enabled!", 0
