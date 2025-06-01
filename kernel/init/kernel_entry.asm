; Ensures that we jump straight into the kernel’s entry function.
[bits 64]
[extern main]

kernel_init:
    call main
    jmp $
