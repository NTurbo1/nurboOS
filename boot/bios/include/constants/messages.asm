; ===================================== DEBUGGING MESSAGES ========================================
CPUID_NOT_AVAILABLE             db "CPUID is not available :(", 0
LOADING_NEXT_KERNEL_CHUNK_MSG   db "Loading the next chunk of kernel code...", 13, 10, 0 
PROTECTED_MODE_MSG              db "Switched to 32-bit Proected Mode!", 0
KERNEL_LOAD_SUCCESS_MSG         db "Successfully loaded the kernel!", 13, 10, 0
LOADING_LAST_KERNEL_SECTORS_MSG db "Loading the last sectors of kernel...", 13, 10, 0
LOADING_KERNEL_MSG              db "Loading kernel into memory...", 13, 10, 0
DISK_ERROR_MESSAGE              db "Disk read error!", 13, 10, 0
DISK_LOAD_STATUS_MESSAGE        db "Disk load status: ", 0
RETRYING_DISK_LOADING           db "Retrying disk loading ...", 13, 10, 0
DONE_DISK_LOADING_RETURNING     db "Done disk loading, returning ...", 13, 10, 0
KERNEL_LOAD_DISK_READ_ERROR_MSG db "Disk read error during kernel loading with LBA!", 13, 10, 0
STARTED_SWITCHING_TO_PM_MSG     db "Started switching to 32-bit Protected Mode", 13, 10, 0
LOADED_GDT_MSG                  db "Loaded GDT (Global Descriptor Table)", 13, 10, 0
A20_IS_NOT_SET_MSG              db "A20 is not set.", 0
A20_IS_SET_MSG                  db "A20 is set!", 0
ENABLING_A20_MSG                db "Enabling the A20 lint...", 0
GIVE_UP_ENABLING_A20_MSG        db "Couldn't enable the A20 line... Give up :(", 0
SET_LM_BIT_MSG                  db "Set LM-bit.", 0
PAGING_ENABLED_MSG              db "Paging is enabled!", 0

INITIALIZING_SEGMENT_REGISTERS_IN_PM    db "Initializing segment registers in Protected Mode.", 0 ;
LONG_MODE_NOT_SUPPORTED                 db "64-bit Long Mode is not supported :(", 0
LONG_MODE_SUPPORTED                     db "64-bit Long Mode is supported :)", 0
; CHECKING_CPUID_MSG                      db "Checking CPUID...", 0
; SETTING_UP_PAGING_FOR_LONG_MODE_MSG     db "Setting up Paging for Long Mode...", 0
; PAE_PAGING_IS_ENABLED_MSG               db "PAE paging is enabled!", 0
; ENABLING_PML5_MSG                       db "Enabling PML5 (5 Level Paging)...", 0
; PML5_ENABLED_MSG                        db "PML5 (5 Level Paging) is enabled!", 0
; PML5_NOT_SUPPORTED_MSG                  db "PML5 is not supported!", 0
INSIDE_PRINT_STRING_PM db "Printing in protected mode...", 0
