.globl gdt_flush
gdt_flush:
    movl 4(%esp), %eax      # eax = pointer to gdt_ptr
    lgdt (%eax)             # load GDTR from [eax]

    movw $0x10, %ax         # data segment selector = 0x10
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %fs
    movw %ax, %gs
    movw %ax, %ss

    ljmp $0x08, $.flush     # far jump: load CS = 0x08

.flush:
    ret

.globl idt_flush
idt_flush:
    movl 4(%esp), %eax     # eax = pointer to idt_ptr
    lidt (%eax)            # load IDTR from [eax]
    ret
