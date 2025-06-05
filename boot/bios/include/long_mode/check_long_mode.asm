[bits 32]

; Check if CPUID is supported by attempting to flip the ID bit (bit 21) in the FLAGS register. 
; If we can flip it, CPUID is available.
check_cpuid:
    push ebx
    push ecx

    ; Set the registers that will be used in the procedure to 0. 
    ; Modifying their 8, 16, 32 bit parts causes nasty bugs that 
    ; hard to fix.
    xor ebx, ebx
    xor ecx, ecx

    ; Uncomment the below for debugging
    ; mov ebx, CHECKING_CPUID_MSG
    ; call print_string_pm

    pushfd                              ; Save EFLAGS
    pop eax                             ; EAX = original EFLAGS
    mov ecx, eax                        ; ECX = copy of original EFLAGS
    xor eax, 0x00200000                 ; Invert the ID bit (bit 21) in stored EFLAGS
    push eax
    popfd                               ; Load stored EFLAGS (with ID bit inverted)
    
    pushfd                              ; Store EFLAGS again (ID bit may or may not 
                                        ; be inverted)

    pop eax                             ; eax = modified EFLAGS (ID bit may or 
                                        ; may not be inverted)

    xor eax, ecx                        ; eax = whichever bits were changed
    and eax, 0x00200000                 ; eax = zero if ID bit can't be changed -> CPUID is not supported :(, 
                                        ; else non-zero -> CPUID is supported :)

    push ecx
    popfd                               ; Restore original EFLAGS

    pop ecx
    pop ebx
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
    jmp $

.return:
    pop edx
    pop ebx
    pop eax

    ret
