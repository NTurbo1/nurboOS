[bits 16]

; Switch to protected mode
switch_to_pm:
    mov bx, STARTED_SWITCHING_TO_PM_MSG
    call print_string ; external procedure

    cli     ; We must switch off interrupts until we have
            ; set up the protected mode interrupt vector,
            ; otherwise interrupts will run riot.

    lgdt [gdt_descriptor]       ; Load our global descriptor table, which defines
                                ; the protected mode segments (e.g. for code and data)

    mov bx, LOADED_GDT_MSG
    call print_string

    mov eax, cr0                ; To make the switch to protected mode, we set
    or eax, 0x1                 ; the first bit of CR0, a control register
    mov cr0, eax

    ; CODE_SEG is defined in gdt asm file.
    jmp CODE_SEG:init_pm        ; Make a far jump (i.e. to a new segment) to our 32-bit
                                ; code. This also forces the CPU to flush its cache of
                                ; pre-fetched and real-mode decoded instructions, which can
                                ; cause problems if not flushed.

[bits 32]

; Initialise registers and the stack once in PM.
init_pm:
    mov ebx, INITIALIZING_SEGMENT_REGISTERS_IN_PM
    call print_string_pm

    mov ax, DATA_SEG        ; Now in PM, our old segments are meaningless,
    mov ds, ax              ; so we point our segment registers to the
    mov ss, ax              ; data selectors we defined in our GDT
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov ebp, 0x90000        ; Update our stack position so it is right
    mov esp, ebp            ; at the top of the free space.
    call BEGIN_PM           ; Finally, call some well-known label, defined in boot sector asm file.
