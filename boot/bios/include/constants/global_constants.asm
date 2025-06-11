; *************************************************************************************************
; ************************************** GLOBAL CONSTANTS *****************************************
; *************************************************************************************************
SECTOR_BYTES_COUNT                  equ 512         ; Number of bytes in one sector
SECOND_STAGE_BOOT_SECTORS_COUNT     equ 7           ; Number of sectors loaded after the 1st sector
KERNEL_OFFSET                       equ 0x00100000  ; The kernel entry point at the 1st MiB of the 
                                                    ; physical address.
MAX_SECTORS_NUM_CAN_BE_READ_AT_ONCE equ 8 

; *************************************** VGA CONSTANTS *******************************************
VGA_ADDRESS                                     equ 0xb8000
WHITE_ON_BLACK                                  equ 0x0f
VGA_WIDTH                                       equ 80
VGA_HEIGHT                                      equ 25
VGA_REGISTER_INDEX_PORT                         equ 0x3d4
VGA_REGISTER_DATA_PORT                          equ 0x3d5
VGA_CURSOR_LOCATION_HIGH_BYTE_REG               equ 0x0e 
VGA_CURSOR_LOCATION_LOW_BYTE_REG                equ 0x0f



; *************************************************************************************************
; ************************************** GLOBAL VARIABLES *****************************************
; *************************************************************************************************
KERNEL_SECTORS_LEFT dw 4096         ; Assuming the kernel code size is no bigger than 
                                    ; 2 MiB = 4096 * 512 (sector size).
                                    ; Note: should be updated accordingly as the kernel size grows.

