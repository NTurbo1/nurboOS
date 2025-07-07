.code32
.align 4

.section .text
.global setup_paging 
.type setup_paging, @function
# We'll set up four tables at 0x1000: a PML4T, a PDPT, a PDT and a PT. Basically we want to 
# identity map the first two megabytes so:
#
#     PML4T[0] -> PDPT.
#     PDPT[0] -> PDT.
#     PDT[0] -> PT.
#     PT -> 0x00000000 - 0x00200000
#
# The page tables are going to be located at these addresses:
#
#     PML4T - 0x1000.
#     PDPT - 0x2000.
#     PDT - 0x3000.
#     PT - 0x4000.
setup_paging:
    pushal

    xorl %ebx, %ebx              # Set EBX to 0 to be used properly below. 

    # Clear tables
    movl $0x1000, %edi          # Set the destination index to 0x1000.
    movl %edi, %cr3              # Set control register 3 to the destination index.
    xorl %eax, %eax              # Nullify the A-register.
    movl $4096, %ecx             # Set the C-register to 4096.
    rep stosl                   # Clear the memory.
    movl %cr3, %edi              # Set the destination index to control register 3.

    # Make PML4T[0] point to the PDPT and so on.
    #
    # The 3 at the end of the address values below simply means that the first two bits 
    # should be set. These bits indicate that the page is present and that it is readable 
    # as well as writable. 
    # Since page table entries are page size (4 KiB) aligned, CPU uses the last 12 bits 
    # (extracted by masking out the last 12 bits by entry & 0xFFFFFFFFFFFFF000) for flag
    # bits to store information about the page. 
    movl $0x2003, (%edi)         # Set the uint32_t at the destination index to 0x2003.
    addl $0x1000, %edi           # Add 0x1000 to the destination index.
    movl $0x3003, (%edi)         # Set the uint32_t at the destination index to 0x3003.
    addl $0x1000, %edi           # Add 0x1000 to the destination index.
    movl $0x4003, (%edi)         # Set the uint32_t at the destination index to 0x4003.
    addl $0x1000, %edi           # Add 0x1000 to the destination index.

    # Identity map the first two megabytes
    movl $0x00000003, %ebx       # Set the B-register to 0x00000003.
    movl $512, %ecx              # Set the C-register to 512.
    
1:
    movl %ebx, (%edi)
    addl $0x1000, %ebx           # Add 0x1000 to the B-register.
    addl $8, %edi                # Add eight to the destination index.
    loop 1b                     # Set the next entry.

    # Mapping virtual address 0xFFFFFFFF80000000 (high canonical address) -> physical 0x00100000 (kernel location)
    # Kernel code is put in the high half canonical (virtual) address and user space code is put in the low half 
    # canonical (virtual) address by convention. We use 2 MiB pages (bit 7 = PS = Page Size)

    # 1. Compute the indices:
    #    PML4[511] (because bit 47 = 1) -> PDPT[0] -> PDT[0] -> 2 MiB page at 0x00100000

    # Add new page tables at:
    # PML4T (512 GiB each) at 0x1000            <- already used
    # PDPT (1 GiB each) at 0x2000               <- already used
    # PDT (2 MiB each) at 0x3000                <- already used (for identity map)
    # PT (4 KiB(page size) each) at 0x4000      <- already used 
    # 0x4000 - 0x5000(not included)             <- already used for identity mapping the 1st 2 MiB of memory, which
    #                                              referenced by the 1st entry in PDT.
    # Use new ones at 0x5000, 0x6000
    movl $0x1000, %edi                   # PML4T
    movl $0x5003, 4088(%edi)             # PML4[511] -> PDPT_HH at 0x5000. 4088 = 8 * 511

    movl $0x5000, %edi                   # PDPT_HH
    movl $0x6003, (%edi)                 # PDPT[0] -> PDT_HH at 0x6000

    movl $0x6000, (%edi)                 # PDT_HH
    movl $0x00100083, (%edi)             # Map 2MiB page:
                                        # Present | Write | Page Size (2MiB) | addr=0x00100000

# Enable PAE-paging by setting the PAE-bit in the fourth control register (CR4.PAE).
    movl %cr4, %eax                 # Set the A-register to control register 4.
    orl 1 << 5, %eax                # Set the PAE-bit, which is the 6th bit (bit 5).
    movl %eax, %cr4                 # Set control register 4 to the A-register.

    # Uncomment the below for debugging
    # mov ebx, PAE_PAGING_IS_ENABLED_MSG
    # call print_string_pm

# Now paging is set up, but it isn't enabled yet. 

# Note: The below code that checks if PML5 is supported and enables it if supported is 
# commented out intentionally. Because we're not using PML5 (5 Level Paging) for now, 
# maybe later.

# TODO: Convert the below commented code from NASM to GAS (GNU assembler)

# # Check if PML5 (5 Level Paging) is supported.
#     mov eax, 0x7                        # You might want to check for page 7 first!
#     xor ecx, ecx
#     cpuid
#     test ecx, (1<<16)
#     jnz .enable_5_level_paging
#     mov ebx, PML5_NOT_SUPPORTED_MSG
#     call print_string_pm
#     xor ebx, ebx                        # Set EBX to 0 to be used properly below.
#     jmp .return
#
# # Enables 5-level paging support in hardware (but paging itself must also be turned on later 
# # with CR0/CR3 setup).
# #
# # Note that attempting to set CR4.LA57 while EFER.LMA=1 causes a #GP general protection fault. 
# # You therefore need to drop into protected mode or set up 5 level paging before entering 
# # long mode in the first place. 
# .enable_5_level_paging:
#     mov ebx, ENABLING_PML5_MSG
#     call print_string_pm            # External procedure
#     xor ebx, ebx                    # Set EBX to 0 to be used properly below. 
#
#     BITS 32
#     mov eax, cr4
#     or eax, (1<<12) #CR4.LA57
#     mov cr4, eax
#
#     mov ebx, PML5_ENABLED_MSG
#     call print_string_pm            # External procedure
#     xor ebx, ebx                    # Set EBX to 0 to be used properly below. 

# Return from setup_paging
2:
    popal
    ret

