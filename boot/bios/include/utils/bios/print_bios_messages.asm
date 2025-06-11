[bits 16]

print_loading_kernel_msg:
    push bx
    mov bx, LOADING_KERNEL_MSG
    call print_string
    pop bx
    ret

print_loading_next_kernel_chunk_msg:
    push bx
    mov bx, LOADING_NEXT_KERNEL_CHUNK_MSG
    call print_string
    pop bx
    ret

print_loading_last_kernel_sectors_msg:
    push bx
    mov bx, LOADING_LAST_KERNEL_SECTORS_MSG
    call print_string
    pop bx
    ret

print_kernel_load_success_msg:
    push bx
    mov bx, KERNEL_LOAD_SUCCESS_MSG
    call print_string
    pop bx
    ret
