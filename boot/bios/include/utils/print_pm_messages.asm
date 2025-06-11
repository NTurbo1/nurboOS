[bits 32]

print_protected_mode_msg:
    push bx
    mov ebx, PROTECTED_MODE_MSG
    call print_string_pm
    pop bx
    ret

print_cpu_not_available:
    push ebx
    mov ebx, CPUID_NOT_AVAILABLE
    call print_string_pm
    pop ebx
    ret
