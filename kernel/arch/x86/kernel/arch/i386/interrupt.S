.section .text
.code32

.macro ISR_NOERRCODE num
.globl isr\num
isr\num:
    cli
    pushl $0              # dummy error code
    pushl $\num           # interrupt number
    jmp isr_common_stub
    .endm

    .macro ISR_ERRCODE num
    .globl isr\num
isr\num:
    cli
    pushl $\num           # error code already pushed by CPU
    jmp isr_common_stub
    .endm

.globl isr_common_stub
isr_common_stub:
    pusha                       # Push general-purpose registers

    movw    %ds, %ax            # AX = DS
    pushl   %eax                # Save original DS

    movw    $0x10, %ax          # Load kernel data segment selector
    movw    %ax, %ds
    movw    %ax, %es
    movw    %ax, %fs
    movw    %ax, %gs

    call    isr_handler         # Call the C ISR dispatcher

    popl    %eax                # Restore original DS
    movw    %ax, %ds
    movw    %ax, %es
    movw    %ax, %fs
    movw    %ax, %gs

    popa                        # Restore general-purpose registers
    addl    $8, %esp            # Pop error code + interrupt number
    sti
    iret

# ISRs without error code
ISR_NOERRCODE 0
ISR_NOERRCODE 1
ISR_NOERRCODE 2
ISR_NOERRCODE 3
ISR_NOERRCODE 4
ISR_NOERRCODE 5
ISR_NOERRCODE 6
ISR_NOERRCODE 7
ISR_NOERRCODE 9
ISR_NOERRCODE 15
ISR_NOERRCODE 16
ISR_NOERRCODE 17
ISR_NOERRCODE 18
ISR_NOERRCODE 19
ISR_NOERRCODE 20
ISR_NOERRCODE 21
ISR_NOERRCODE 22
ISR_NOERRCODE 23
ISR_NOERRCODE 24
ISR_NOERRCODE 25
ISR_NOERRCODE 26
ISR_NOERRCODE 27
ISR_NOERRCODE 28
ISR_NOERRCODE 29
ISR_NOERRCODE 30
ISR_NOERRCODE 31

# ISRs with error code
ISR_ERRCODE 8
ISR_ERRCODE 10
ISR_ERRCODE 11
ISR_ERRCODE 12
ISR_ERRCODE 13
ISR_ERRCODE 14
