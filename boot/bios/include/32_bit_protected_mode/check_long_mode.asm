check_cpuid:
    push eax

    pushfd                              ; Save EFLAGS
    pushfd                              ; Store EFLAGS
    xor dword [esp], 0x00200000         ; Invert the ID bit in stored EFLAGS
    popfd                               ; Load stored EFLAGS (with ID bit inverted)

    pushfd                              ; Store EFLAGS again (ID bit may or may not 
                                        ; be inverted)

    pop eax                             ; eax = modified EFLAGS (ID bit may or 
                                        ; may not be inverted)

    xor eax, [esp]                      ; eax = whichever bits were changed
    popfd                               ; Restore original EFLAGS
    and eax, 0x00200000                 ; eax = zero if ID bit can't be changed, 
                                        ; else non-zero

    pop eax
    ret                                 ; returns from check_cpuid.

; TODO: Explore the below notes!

; Note 1: There are some old CPUs where CPUID is supported but the ID bit in EFLAGS 
; is not (NexGen). There are also CPUs that support CPUID if and only if it has to 
; be enabled first (Cyrix M1).

; Note 2: You can simply attempt to execute the CPUID instruction and see if you 
; get an invalid opcode exception. This avoids problems with CPUs that do support 
; CPUID but don't support the ID bit in EFLAGS; and is likely to be faster for CPUs 
; that do support CPUID (and slower for CPUs that don't). 

check_long_mode_supported:
    push eax
    push ebx
    push edx

    mov eax, 0x80000000     ; Set the A-register to 0x80000000.
    cpuid                   ; CPU identification.
    cmp eax, 0x80000001     ; Compare the A-register with 0x80000001.
    jb .noLongMode          ; It is less, there is no long mode.

    mov eax, 0x80000001     ; Set the A-register to 0x80000001.
    cpuid                   ; CPU identification.
    test edx, 1 << 29       ; Test if the LM-bit, which is bit 29, is set in the D-register.
    jz .noLongMode          ; They aren't, there is no long mode.

    mov ebx, LONG_MODE_SUPPORTED
    call print_string_pm
    jmp .return

.noLongMode:
    mov ebx, LONG_MODE_NOT_SUPPORTED  
    call print_string_pm                ; external procedure from print_pm.asm file.

.return:
    pop edx
    pop ebx
    pop eax

    ret

; Debugging messages
LONG_MODE_NOT_SUPPORTED db "64-bit Long Mode is not supported :(", 13, 10, 0
LONG_MODE_SUPPORTED db "64-bit Long Mode is supported :)", 13, 10, 0
