.code32
.align 8

.section .data
jump64:
    .quad realm64                   # 8 byte offset (64-bit address)
    .word GDT64_code                # 2 byte code segment selector

.section .text
# Set the long mode bit in the EFER MSR and then enable paging and then 
# we are in compatibility mode (which is part of long mode)
.global switch_to_lm_from_pm 
.type switch_to_lm_from_pm, @function 
switch_to_lm_from_pm:
    pushal

    # Set the LM-bit.
    movl 0xC0000080, %ecx           # Set the C-register to 0xC0000080, which is the EFER MSR (Model Specific Register).
    rdmsr                           # Read from the model specific register.
    orl 1 << 8, %eax                # Set the LM-bit which is the 9th bit (bit 8).
    wrmsr                           # Write to the model specific register.

    # Enable paging.
    movl %cr0, %eax                 # Set the A-register to control register 0.
    orl 1 << 31, %eax               # Set the PG-bit, which is the 32nd bit (bit 31).
    movl %eax, %cr0                 # Set control register 0 to the A-register.

    # Now we're in compatibility mode.

    # Load GDT for Long Mode and jump to 64-bit.  
    lgdt (GDT64_pointer)            # Load the 64-bit global descriptor table.
    ljmp *jump64                    # Set the code segment and enter 64-bit long mode.

.code64

realm64:
    cli                                 # Clear the interrupt flag.
    movw $GDT64_data, %ax               # Set the A-register to the data descriptor.
    movw %ax, %ds                       # Set the data segment to the A-register.
    movw %ax, %es                       # Set the extra segment to the A-register.
    movw %ax, %fs                       # Set the F-segment to the A-register.
    movw %ax, %gs                       # Set the G-segment to the A-register.
    movw %ax, %ss                       # Set the stack segment to the A-register.

    movl 0xB8000, %edi                  # Set the destination index to 0xB8000 
                                        # (the VGA (Video Graphics Array) address).
    movq 0x1F201F201F201F20, %rax       # Set the A-register to 0x1F201F201F201F20 
                                        # (white spaces with blue background).
    movl 500, %ecx                      # Set the C-register to 500.
    rep stosq                           # Clear the screen.
    hlt

# Return from switch_to_lm_from_pm
2:
    popal
    ret
