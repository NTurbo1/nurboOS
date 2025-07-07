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
