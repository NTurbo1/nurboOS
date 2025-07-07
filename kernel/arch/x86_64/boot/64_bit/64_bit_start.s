.code64
.global realm64

realm64:
    # cli                                 # Clear the interrupt flag.
    # movw $GDT64_data, %ax               # Set the A-register to the data descriptor.
    # movw %ax, %ds                       # Set the data segment to the A-register.
    # movw %ax, %es                       # Set the extra segment to the A-register.
    # movw %ax, %fs                       # Set the F-segment to the A-register.
    # movw %ax, %gs                       # Set the G-segment to the A-register.
    # movw %ax, %ss                       # Set the stack segment to the A-register.
    #
    # movl 0xB8000, %edi                  # Set the destination index to 0xB8000 
    #                                     # (the VGA (Video Graphics Array) address).
    # movq 0x1F201F201F201F20, %rax       # Set the A-register to 0x1F201F201F201F20 
    #                                     # (white spaces with blue background).
    # movl 500, %ecx                      # Set the C-register to 500.
    # rep stosq                           # Clear the screen.
    # 
    # call kernel_main

    movw $0x0F48, 0xB8000   # Print 'H' (0x48) with white on black at top-left

halt_loop:
    hlt
    jmp halt_loop 
